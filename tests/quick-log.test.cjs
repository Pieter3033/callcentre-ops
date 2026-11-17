const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const crypto = require('node:crypto');
const policy = require('../quick_log_policy.js');
const drafts = require('../../internaltickets/quick-log-drafts.js');

const row = (overrides = {}) => ({ comm_type: 'Call Made', contact_name: 'Test contact', contact_no: '+27 (82) 123-4567', email_address: 'test@example.invalid', datetime_comm: '2026-10-06 10:30:00', comments: 'Test notes', ...overrides });

test('phone normalization keeps one international number and rejects explanatory text, two numbers and non-ASCII digits', () => {
 assert.equal(policy.normalizePhone('+27 (82) 123-4567'), '+27821234567');
 assert.equal(policy.normalizePhone('082\u00a0123\u202f4567'), '0821234567');
 assert.equal(policy.normalizePhone(''), '');
 for (const invalid of ['0821234567 / 0831234567', 'Call 0821234567', '１２３４５６７', '++27821234567', '123456', '1234567890123456']) assert.throws(() => policy.normalizePhone(invalid));
});

test('contact numbers accept safe local/international formatting and reject incomplete or ambiguous input',()=>{
 for(const [input,expected] of [['082 123 4567','0821234567'],['(011) 123-4567','0111234567'],['+27 (0)82 123-4567','+27821234567'],['0027 (0)82 1234567','+27821234567'],['00 44 20 7946 0958','+442079460958'],['+1 (212) 555-0123','+12125550123'],['\u00a0082\u202f123 4567\u00a0','0821234567'],['+123456789012345','+123456789012345'],['',''],[null,'']]) assert.equal(policy.normalizePhone(input),expected,input);
 for(const input of ['fdfdxdxxghfdx','082123456','821234567','27821234567','123456789012345','+270821234567','+2782123456','+278212345678','+0123456789','0821234567,0831234567','0821234567 / 0831234567','0821234567\n0831234567','082\t1234567','0821234567 ext 2','(0821234567','082)1234567','((082))1234567','(08212)34567','082\u200b1234567','٠٨٢١٢٣٤٥٦٧','0000000000','0821234567'+' '.repeat(80)+'1']) assert.throws(()=>policy.normalizePhone(input),undefined,input);
});

test('invalid contact numbers cannot send a request, and the original text is kept for correction',async()=>{
 let calls=0;const h=harness(async()=>{calls++;});
 h.fieldRows[0].querySelector("[data-field='contact_no']").value='fdfdxdxxghfdx';
 await h.submit();assert.equal(calls,0);assert.match(h.nodes.get('#quickLogMessage').textContent,/highlighted contact numbers/);
 assert.equal(h.fieldRows[0].querySelector("[data-field='contact_no']").value,'fdfdxdxxghfdx');
 assert.equal(h.fieldRows[0].querySelector("[data-field='contact_no']").focused,true);
});

test('draft save validates every number, preserves the previous draft on failure, and normalizes valid numbers only on saving',()=>{
 const h=harness(async()=>{throw Error('Draft saving must not send a request');});
 assert.equal(h.read('saveQuickLogDraft()'),true);
 const original=[...h.storage.values()][0];
 const first=h.fieldRows[0].querySelector("[data-field='contact_no']"),second=h.fieldRows[1].querySelector("[data-field='contact_no']");
 first.value='bad number';second.value='082123';
 assert.equal(h.read('saveQuickLogDraft()'),false);
 assert.equal([...h.storage.values()][0],original);assert.equal(first.value,'bad number');assert.equal(second.value,'082123');
 assert.equal(first.attributes.get('aria-invalid'),'true');assert.equal(second.attributes.get('aria-invalid'),'true');assert.equal(first.focused,true);
 first.value='+27 (0)82 123-4567';second.value='';
 assert.equal(h.read('saveQuickLogDraft()'),true);
 const saved=JSON.parse([...h.storage.values()][0]);assert.equal(saved.rows[0].contactNo,'+27821234567');assert.equal(saved.rows[1].contactNo,'');
 assert.equal(first.value,'+27821234567');assert.equal(first.attributes.has('aria-invalid'),false);assert.equal(second.attributes.has('aria-invalid'),false);
});

test('inline validation marks bad numbers and clears the error when a formatted number is corrected',()=>{
 const h=harness(async()=>{}),message={hidden:true,textContent:''},attributes=new Map();
 const input={value:'bad number',validationMessage:'',closest:()=>({querySelector:()=>message}),setCustomValidity(value){this.validationMessage=value;},setAttribute:(key,value)=>attributes.set(key,value),removeAttribute:key=>attributes.delete(key)};
 h.context.phoneInput=input;
 assert.equal(h.read('validateQuickLogPhone(phoneInput)'),false);assert.equal(attributes.get('aria-invalid'),'true');assert.equal(message.hidden,false);
 input.value='082 123 4567';assert.equal(h.read('validateQuickLogPhone(phoneInput,true)'),true);
 assert.equal(input.value,'0821234567');assert.equal(input.validationMessage,'');assert.equal(message.hidden,true);assert.equal(attributes.has('aria-invalid'),false);
});

test('validation keeps all rows in order and enforces the total case limit without truncation', () => {
 const rows = [row({ comments: 'First' }), row({ comments: 'Second' })];
 assert.deepEqual(policy.validateRows(rows).map(r => r.comments), ['First', 'Second']);
 assert.equal(policy.validateRows(Array.from({length:100}, () => row())).length,100);
 assert.throws(() => policy.validateRows(rows, 99));
 assert.throws(() => policy.validateRows(Array.from({length:101}, () => row())));
 assert.equal(rows[0].contact_no, '+27 (82) 123-4567');
});

test('validation rejects rollover dates, blank notes and oversized fields; accepts the exact notes boundary', () => {
 assert.equal(policy.validateRows([row({ comments:'x'.repeat(2000) })])[0].comments.length,2000);
 assert.equal(policy.validateRows([row({ datetime_comm:'2028-02-29 23:59:59' })]).length,1);
 for (const invalid of [row({datetime_comm:'2026-02-30 10:30:00'}),row({datetime_comm:'2026-10-06 24:00:00'}),row({datetime_comm:'1700-01-01 00:00:00'}),row({comments:' '}),row({comments:'x'.repeat(2001)}),row({contact_name:'x'.repeat(201)}),row({email_address:'invalid'}),row({comm_type:''})]) assert.throws(() => policy.validateRows([invalid]));
});

function harness(fetchImpl, { storageFails = false, existingCount = 0, sharedStorage = new Map(), completed = false } = {}) {
 const storage = sharedStorage;
 const memoryStorage = map => ({get length(){return map.size;},key:i=>[...map.keys()][i]??null,getItem:k=>map.get(k)??null,setItem(k,v){if(storageFails)throw new Error('Storage blocked');map.set(k,v);},removeItem:k=>map.delete(k)});
 const controls = [];
 const draftRows = [row({comments:'First'}),row({comments:'Second'})];
 const fieldRows = draftRows.map(values => {
  const fields = Object.fromEntries(Object.entries(values).map(([key,value]) => [key,{value:key === 'datetime_comm' ? value.replace(' ','T') : value,disabled:false,attributes:new Map(),focus(){this.focused=true;},setCustomValidity(message){this.validationMessage=message;},setAttribute(name,value){this.attributes.set(name,value);},removeAttribute(name){this.attributes.delete(name);},closest:()=>null}]));
  controls.push(...Object.values(fields));
  return { querySelector(selector) { return fields[selector.match(/data-field=['"]([^'"]+)/)?.[1]]; } };
 });
 const nodes = new Map();
 const node = id => { if (!nodes.has(id)) nodes.set(id,{value:'',textContent:'',hidden:false,dataset:{},disabled:false}); return nodes.get(id); };
 node('#quickLogSeat').value='1';
 node('#quickLogRows').querySelectorAll = selector => selector === '.quick-log-row' ? fieldRows : selector.includes('comm_type') ? fieldRows.map(r => r.querySelector("[data-field='comm_type']")) : selector.includes('contact_no') ? fieldRows.map(r => r.querySelector("[data-field='contact_no']")) : [];
 node('#quickLogForm').reportValidity = () => true;
 node('#quickLogForm').querySelectorAll = () => [...controls,node('#quickLogSeat'),node('#quickLogSubmitButton')];
 const context = vm.createContext({ console, URL, URLSearchParams, Date, FormData, AbortSignal, QuickLogPolicy:policy, crypto:crypto.webcrypto,
  window:{QuickLogDrafts:drafts,location:{search:'?reg_no=TEST&event=Test'+(completed?'&completed=1':''),href:'http://localhost/CC_Escalation/main.sql?reg_no=TEST&event=Test'},history:{replaceState(){}},clearTimeout,setTimeout},
  document:{querySelector:node}, navigator:{}, localStorage:memoryStorage(storage),
  sessionStorage:memoryStorage(new Map()),
  fetch:fetchImpl, setTimeout,clearTimeout });
 const source = fs.readFileSync(path.join(__dirname,'../cc_escalation.js'),'utf8').replace(/\ninit\(\);\s*$/,'');
 vm.runInContext(source,context);
 vm.runInContext(`const realRefreshQuickLogStatus=refreshQuickLogStatus;const realLoadOpenQuickLogCount=loadOpenQuickLogCount;loadOpenQuickLogCount=async()=>{};state.quickLogOptions={authorized:true,submissionEnabled:true,csrfToken:'test',operator:{username:'test',name:'Test operator'},seats:[{value:'1',label:'Test seat'}],commTypes:[{value:'Call Made',label:'Call Made'}]};state.pageData={quickLogComments:Array(${existingCount}).fill({})};resetQuickLogRows=()=>{};refreshQuickLogStatus=async()=>{};`,context);
 return {context,storage,nodes,fieldRows,submit:() => vm.runInContext('submitQuickLog({preventDefault(){}})',context),refreshStatus:()=>vm.runInContext('realRefreshQuickLogStatus()',context),read:expr => vm.runInContext(expr,context)};
}

test('completed view displays the returned Zoho OB as text only after confirmation',async()=>{
 for(const [syncState,zohoOb,expected] of [['Complete',' 994119 ','Log completed · confirmed in Zoho. Zoho OB: 994119'],['Complete',null,'Log completed · confirmed in Zoho.'],['Unconfirmed','994119','Log submitted · Zoho confirmation: Unconfirmed']]){
  const h=harness(async()=>({ok:true,text:async()=>JSON.stringify({authorized:true,logs:[{caseId:77,regNo:'TEST',eventName:'Test',syncState,zohoOb,communicationLog:[]}]})}),{completed:true});
  h.read("seqno='77';document.body={classList:{add(){}}};");await h.read('openQuickLog()');
  assert.equal(h.nodes.get('#quickLogMessage').textContent,expected);
 }
});

test('status polling includes the confirmed Zoho OB when submission finishes',async()=>{
 const h=harness(async()=>({ok:true,text:async()=>JSON.stringify({authorized:true,status:'ok',syncState:'Complete',zohoOb:' 994119 '})}));
 h.read("seqno='77';");await h.refreshStatus();
 assert.equal(h.nodes.get('#quickLogMessage').textContent,'All saved communication entries are confirmed in Zoho. Zoho OB: 994119');
});

function confirmed(body) { return {ok:true,text:async()=>JSON.stringify({success:true,caseId:123,insertedComments:JSON.parse(body.get('comments_json')).length,submissionId:body.get('submission_id'),message:'Saved'})}; }

test('a lost response preserves the draft and retries the exact request ID and complete ordered payload',async()=>{
 const requests=[];
 const h=harness(async(url,options)=>{requests.push(options.body);if(requests.length===1)throw new Error('Connection lost');return confirmed(options.body);});
 await h.submit();
 assert.equal(h.storage.size,1);
 assert.equal(h.read('Boolean(quickLogAttemptFingerprint)'),true);
 assert.equal(h.nodes.get('#quickLogSeat').disabled,true);
 assert.equal(h.nodes.get('#quickLogSubmitButton').disabled,false);
 await h.submit();
 assert.equal(requests.length,2);
 assert.equal(requests[0].get('submission_id'),requests[1].get('submission_id'));
 assert.equal(requests[0].get('comments_json'),requests[1].get('comments_json'));
 assert.deepEqual(JSON.parse(requests[0].get('comments_json')).map(r=>r.comments),['First','Second']);
 assert.equal(h.storage.size,0);
 assert.equal(h.read('seqno'),'123');
});

test('double submission sends only one POST while the first response is pending',async()=>{
 let calls=0,release;
 const pending=new Promise(resolve=>release=resolve);
 const h=harness(async(url,options)=>{calls++;await pending;return confirmed(options.body);});
 const first=h.submit();
 await Promise.resolve();
 const second=h.submit();
 release();await Promise.all([first,second]);
 assert.equal(calls,1);
});

test('storage failure and unavailable backend never send a POST',async()=>{
 let calls=0;
 const blocked=harness(async()=>{calls++;},{storageFails:true});
 await blocked.submit();assert.equal(calls,0);
 const unavailable=harness(async()=>{calls++;});
 vm.runInContext('state.quickLogOptions.submissionEnabled=false',unavailable.context);
 await unavailable.submit();assert.equal(calls,0);
});

test('an unexpected confirmation retains the request, and altered retries cannot rotate its key',async()=>{
 let calls=0;
 const h=harness(async(url,options)=>{calls++;return {ok:true,text:async()=>JSON.stringify({success:true,caseId:123,insertedComments:1,submissionId:options.body.get('submission_id')})};});
 await h.submit();const original=h.read('quickLogSubmissionId');
 assert.equal(h.storage.size,1);
 h.fieldRows[0].querySelector("[data-field='comments']").value='Edited after ambiguous response';
 await h.submit();assert.equal(calls,1);assert.equal(h.read('quickLogSubmissionId'),original);
 assert.equal(h.read('Boolean(quickLogAttemptFingerprint)'),true);
});

test('a definite atomic validation rollback unlocks corrections without discarding entries',async()=>{
 const h=harness(async()=>({ok:false,status:500,text:async()=>'<html>CC_VALIDATION: check entries</html>'}));
 await h.submit();assert.equal(h.read('quickLogAttemptFingerprint'),null);
 assert.equal(h.nodes.get('#quickLogSeat').disabled,false);
 assert.equal(h.storage.size,1);
 assert.equal(h.fieldRows[0].querySelector("[data-field='comments']").value,'First');
});

test('a stale tab cannot overwrite or submit a newer shared draft',async()=>{
 let calls=0;
 const sharedStorage=new Map();
 const first=harness(async()=>{calls++;},{sharedStorage});
 const stale=harness(async()=>{calls++;},{sharedStorage});
 assert.equal(first.read('saveQuickLogDraft()'),true);
 const saved=[...sharedStorage.values()][0];
 stale.fieldRows[0].querySelector("[data-field='comments']").value='Stale tab edit';
 await stale.submit();
 assert.equal(calls,0);
 assert.equal([...sharedStorage.values()][0],saved);
 assert.match(stale.nodes.get('#quickLogMessage').textContent,/No request was sent/);
});

test('confirmed submission does not delete a draft changed while its response was pending',async()=>{
 let release,submitted;
 const pending=new Promise(resolve=>release=resolve);
 const h=harness(async(url,options)=>{submitted=options.body;await pending;return confirmed(options.body);});
 const sending=h.submit();
 await Promise.resolve();
 const [key,raw]=[...h.storage.entries()][0];
 const changed=JSON.parse(raw);changed.rows[0].comments='New shared draft';changed.submissionId=null;changed.attemptFingerprint=null;
 h.storage.set(key,JSON.stringify(changed));
 release();await sending;
 assert.ok(submitted);
 assert.equal(JSON.parse(h.storage.get(key)).rows[0].comments,'New shared draft');
});
test('completed log viewing cannot submit or save a browser draft',async()=>{
 let calls=0;const h=harness(async()=>{calls++;},{completed:true});
 await h.submit();assert.equal(calls,0);assert.equal(h.read('saveQuickLogDraft()'),false);assert.equal(h.storage.size,0);
});

test('closing an existing open log sends its complete edited row set and original snapshot',async()=>{
 let submitted;
 const h=harness(async(url,options)=>{submitted=options.body;return confirmed(options.body);});
 h.fieldRows[0].dataset={commId:'41'};
 h.fieldRows[1].dataset={commId:'42'};
 h.fieldRows[0].querySelector("[data-field='comments']").value='Edited original communication';
 h.read("seqno='77';quickLogBaseSnapshot='original-snapshot';state.pageData.quickLogCase={closed:false,snapshot:'original-snapshot'};");
 await h.submit();
 const rows=JSON.parse(submitted.get('comments_json'));
 assert.deepEqual(rows.map(r=>r.comm_id),[41,42]);
 assert.equal(rows[0].comments,'Edited original communication');
 assert.equal(submitted.get('case_snapshot'),'original-snapshot');
 assert.equal(h.read('quickLogIsClosed()'),true);
 assert.equal(h.read('saveQuickLogDraft()'),false);
});

test('an existing log cannot submit without a current server snapshot',async()=>{
 let calls=0;const h=harness(async()=>{calls++;});
 h.read("seqno='77';");await h.submit();
 assert.equal(calls,0);
 assert.match(h.nodes.get('#quickLogMessage').textContent,/Reload this open log/);
});

test('closed case metadata prevents saves and submissions even without a completed URL flag',async()=>{
 let calls=0;const h=harness(async()=>{calls++;});
 h.read('state.pageData.quickLogCase={closed:true};');
 await h.submit();assert.equal(h.read('saveQuickLogDraft()'),false);assert.equal(calls,0);
});

test('a completed legacy log with close unset cannot save or submit, and retains its original communication',async()=>{
 let calls=0;const h=harness(async()=>{calls++;});
 h.read("state.pageData={quickLogComments:[],quickLogCase:{closed:false,completed:true,initialCommunication:{commType:'Call Made',contactName:'Original contact',contactNo:'0821234567',comments:'Original legacy note',ccOperator:'Test operator',datetimeComm:'2026-05-26 12:57:13',zohoPushed:1}}};renderQuickLogHistory([]);");
 assert.equal(h.nodes.get('#quickLogHistory').hidden,false);
 assert.match(h.nodes.get('#quickLogHistoryList').innerHTML,/Original legacy note/);
 assert.match(h.nodes.get('#quickLogHistoryList').innerHTML,/Zoho pushed/);
 await h.submit();assert.equal(h.read('saveQuickLogDraft()'),false);assert.equal(calls,0);
});

test('a legacy parent communication loads as one editable row with its full original fields',()=>{
 const h=harness(async()=>{});
 h.read("state.pageData={quickLogComments:[],quickLogCase:{initialCommunication:{commId:0,commType:'Call Made',contactName:'Original contact',contactNo:'0821234567',emailAddress:'original@example.invalid',comments:'Original note',datetimeComm:'2026-05-26 12:57:13'}}};");
 const rows=JSON.parse(JSON.stringify(h.read('existingQuickLogRows()')));
 assert.equal(rows.length,1);assert.equal(rows[0].commId,0);assert.equal(rows[0].comments,'Original note');
 assert.equal(rows[0].emailAddress,'original@example.invalid');assert.equal(rows[0].datetimeComm,'2026-05-26 12:57:13');
 assert.match(h.read('quickLogRowTemplate(existingQuickLogRows()[0])'),/2026-05-26T12:57:13/);
});

test('restoring a stale complete-log draft preserves it and blocks submission',async()=>{
 let calls=0;const h=harness(async()=>{calls++;});
 h.read("seqno='77';quickLogBaseSnapshot='old';");assert.equal(h.read('saveQuickLogDraft()'),true);
 const raw=[...h.storage.values()][0];h.read("quickLogBaseSnapshot='changed';restoreQuickLogDraft();");
 assert.match(h.nodes.get('#quickLogMessage').textContent,/changed after the draft/);
 await h.submit();assert.equal(calls,0);assert.equal([...h.storage.values()][0],raw);
});


test('sidebar count includes new owned drafts without double-counting existing cases and survives failed refreshes',async()=>{
 let response={authorized:true,operator:{username:'test',name:'Test operator'},totalOpenCount:4};
 const urls=[];const h=harness(async(url)=>{urls.push(url);if(response instanceof Error)throw response;return {ok:true,text:async()=>JSON.stringify(response)};});
 assert.equal(h.read('saveQuickLogDraft()'),true);
 const [key,raw]=[...h.storage.entries()][0];
 h.storage.set(key.replace('"new"','"77"'),raw);
 h.storage.set(key.replace('"test"','"someone_else"'),raw);
 await h.read('realLoadOpenQuickLogCount()');
 assert.equal(h.nodes.get('#ccOpenLogsCount').textContent,'5');
 assert.equal(h.nodes.get('#ccOpenLogsCount').hidden,false);
 assert.equal(urls[0],'/internaltickets/api_open_quick_logs_count.sql');
 response=Error('Offline');await h.read('realLoadOpenQuickLogCount()');
 assert.equal(h.nodes.get('#ccOpenLogsCount').textContent,'5');
 response={authorized:false,totalOpenCount:0};await h.read('realLoadOpenQuickLogCount()');
 assert.equal(h.nodes.get('#ccOpenLogsCount').hidden,true);
 response={authorized:true,operator:{username:'test',name:'Test operator'},totalOpenCount:0};h.storage.clear();await h.read('realLoadOpenQuickLogCount()');
 assert.equal(h.nodes.get('#ccOpenLogsCount').textContent,'0');assert.equal(h.nodes.get('#ccOpenLogsCount').hidden,false);
});

test('an older sidebar response cannot overwrite the newer count after submission',async()=>{
 const responses=[];const h=harness(()=>new Promise(resolve=>responses.push(resolve)));
 const first=h.read('realLoadOpenQuickLogCount()');const second=h.read('realLoadOpenQuickLogCount()');
 const result=count=>({ok:true,text:async()=>JSON.stringify({authorized:true,operator:{username:'test',name:'Test operator'},totalOpenCount:count})});
 responses[1](result(0));await second;responses[0](result(1));await first;
 assert.equal(h.nodes.get('#ccOpenLogsCount').textContent,'0');
});
