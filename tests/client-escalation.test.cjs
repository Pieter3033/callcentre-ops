const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),vm=require('node:vm');
const profiles=require('./fixtures/client-profiles.json');
const context=vm.createContext({URL,URLSearchParams,window:{location:{search:'',href:'http://localhost/CC_Escalation/main.sql'}},document:{querySelector(){return null;}}});
vm.runInContext(fs.readFileSync(path.join(__dirname,'../cc_escalation.js'),'utf8').replace(/\ninit\(\);\s*$/,''),context);
const read=(expression,data)=>{context.fixture=data;return vm.runInContext(expression,context);};
test('all six CLIENT contact sets render without the normal five-contact limit',()=>{
 const counts={site_1:3,site_2:3,site_3:3,site_4:7,site_5:6,site_6:5};
 assert.deepEqual(Object.fromEntries(Object.entries(profiles).map(([id,profile])=>[id,profile.dayContacts.length])),counts);
 for(const profile of Object.values(profiles)){
  const html=read('contactSection("Day Contacts","",escalationContacts(fixture).day)',{clientEscalation:profile});
  assert.equal((html.match(/class="contact-card"/g)||[]).length,profile.dayContacts.length);
  const numbers=profile.dayContacts.flatMap(contact=>[contact.number,contact.altNumber]).filter(Boolean);
  assert.equal((html.match(/data-phone=/g)||[]).length,numbers.length);
  assert.ok(numbers.every(number=>html.includes(`data-phone="${number}"`)),'All primary and alternate numbers retained');
  assert.ok(profile.dayContacts.every(contact=>html.includes(contact.name)&&(!contact.notes||html.includes(contact.notes))),'All contact names and notes retained');
 }
});
test('completed unique escalation lists override CLIENT contacts and instructions',()=>{
 const data={clientEscalation:profiles.site_4,uniqueEscalation:{d_c_name_1:'Unique contact',d_c_no_1:'0800000000',n_c_name_1:'Unique night'}};
 const result=read('escalationContacts(fixture)',data);
 assert.equal(result.profile,null);assert.equal(result.day.length,1);assert.equal(result.day[0].name,'Unique contact');assert.equal(result.night[0].name,'Unique night');
 assert.equal(read('clientInstructions(escalationContacts(fixture).profile)',data),'');
});
test('CLIENT uses its full office-hours list and retains Zoho night/weekend contacts and alert notes',()=>{
 const escalation={d_c_name_1:'Zoho day',n_c_name_1:'Zoho night',we_c_name_1:'Zoho weekend',event_note:'Alert-specific note'};
 const result=read('escalationContacts(fixture)',{clientEscalation:profiles.site_4,escalation});
 assert.equal(result.day.length,7);assert.equal(result.night[0].name,'Zoho night');assert.equal(result.weekend[0].name,'Zoho weekend');assert.equal(result.record.event_note,'Alert-specific note');
 const instructions=read('clientInstructions(fixture)',profiles.site_4);assert.ok(instructions.includes('Configure the private escalation policy before use.'));
});
test('ordinary cases retain their existing contacts; instructions escape HTML',()=>{
 const result=read('escalationContacts(fixture)',{escalation:{d_c_name_1:'Existing day'}});assert.equal(result.profile,null);assert.equal(result.day[0].name,'Existing day');
 const html=read('clientInstructions(fixture)',{title:'<img>',instructions:'<script>alert(1)</script>\nNext line'});assert.ok(!html.includes('<script>'));assert.ok(html.includes('&lt;script&gt;'));assert.ok(html.includes('<br>'));
});
