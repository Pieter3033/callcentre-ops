(function (root) {
  "use strict";
  const limits = Object.freeze({ rows: 100, notes: 2000, name: 200, email: 200 });
  function normalizePhone(value) {
    const input = String(value ?? "").replace(/^[ \u00a0\u202f]+|[ \u00a0\u202f]+$/g, "");
    if (!input) return "";
    if (input.length > 80 || /[^0-9+() \u00a0\u202f-]/.test(input)) throw new Error("Enter one phone number only. Put names, extra numbers and explanations in notes.");
    let phone = input.replace(/[ \u00a0\u202f-]/g, "");
    if (/[()]/.test(phone) && !/^[^()]*\([0-9]{1,4}\)[^()]*$/.test(phone)) throw new Error("Check the brackets in this phone number.");
    // An explicitly written South African optional trunk prefix is safe to remove.
    phone = phone.replace(/^(\+27|0027)\(0\)/, "$1").replace(/[()]/g, "");
    if (phone.startsWith("00")) phone = "+" + phone.slice(2);
    if (phone.startsWith("+27")) {
      if (!/^\+27[1-9][0-9]{8}$/.test(phone)) throw new Error("Use +27 followed by 9 digits, without the local leading 0.");
    } else if (phone.startsWith("+")) {
      if (!/^\+[1-9][0-9]{6,14}$/.test(phone)) throw new Error("Use + and a country code with 7–15 digits in total.");
    } else if (!/^0[0-9]{9}$/.test(phone)) {
      throw new Error("Use a 10-digit local number starting with 0, or + and a country code.");
    }
    return phone;
  }
  function validateRows(rows, existingCount = 0) {
    if (!rows.length) throw new Error("Add at least one communication.");
    if (rows.length + existingCount > limits.rows) throw new Error("A case can contain at most 100 communication entries. No entries have been saved.");
    return rows.map((row, index) => {
      const number = index + 1;
      let contactNo;
      try { contactNo = normalizePhone(row.contact_no); }
      catch (error) { throw new Error(`Contact number in entry ${number}: ${error.message}`); }
      const normalized = { ...row, contact_no: contactNo };
      if (!String(row.comm_type || "").trim()) throw new Error(`Select a communication type for entry ${number}.`);
      const parts = /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/.exec(row.datetime_comm || "");
      const date = parts ? new Date(row.datetime_comm.replace(" ", "T")) : null;
      if (!date || !Number.isFinite(date.getTime()) || Number(parts[1]) < 1753 || date.getFullYear() !== Number(parts[1]) || date.getMonth() + 1 !== Number(parts[2]) || date.getDate() !== Number(parts[3]) || date.getHours() !== Number(parts[4]) || date.getMinutes() !== Number(parts[5]) || date.getSeconds() !== Number(parts[6])) throw new Error(`Choose a valid date and time for entry ${number}.`);
      if (!String(row.comments || "").trim() || row.comments.length > limits.notes) throw new Error(`Entry ${number} needs notes of 1–${limits.notes} characters.`);
      if (String(row.contact_name || "").length > limits.name) throw new Error(`The contact name in entry ${number} is too long.`);
      if (String(row.email_address || "").length > limits.email || (row.email_address && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(row.email_address))) throw new Error(`Enter a valid email address for entry ${number}.`);
      return normalized;
    });
  }
  const policy = Object.freeze({ limits, normalizePhone, validateRows });
  if (typeof module !== "undefined" && module.exports) module.exports = policy;
  root.QuickLogPolicy = policy;
})(typeof globalThis !== "undefined" ? globalThis : window);
