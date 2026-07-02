// Google Apps Script Web App for Student Services Company
// This script acts as a REST API backend using Google Sheets as database

// شناسه Google Sheet شما
const SPREADSHEET_ID = '1kbY1V3j2uKmALnd6pWsPW6F9kVecFKnCpnDRLkIKhVo';

// Sheet Names
const USERS_SHEET = 'Users';
const TASKS_SHEET = 'Tasks';
const CHECKLIST_SHEET = 'Checklist';

// Get or create sheet with formatting
function getOrCreateSheet(sheetName, headers) {
  const ss = SpreadsheetApp.openById(SPREADSHEET_ID);
  let sheet = ss.getSheetByName(sheetName);
  
  if (!sheet) {
    sheet = ss.insertSheet(sheetName);
    
    // Add headers
    sheet.appendRow(headers);
    
    // Format header row
    const headerRange = sheet.getRange(1, 1, 1, headers.length);
    headerRange.setFontWeight('bold');
    headerRange.setBackground('#4285f4');
    headerRange.setFontColor('#ffffff');
    headerRange.setHorizontalAlignment('center');
    
    // Auto-resize columns
    for (let i = 1; i <= headers.length; i++) {
      sheet.autoResizeColumn(i);
    }
    
    // Freeze header row
    sheet.setFrozenRows(1);
    
    Logger.log('Sheet "' + sheetName + '" created with headers: ' + headers.join(', '));
  }
  
  return sheet;
}

// Initialize all sheets with headers
// این تابع را یکبار اجرا کنید تا همه sheet‌ها و ستون‌ها ساخته شوند
function initializeSheets() {
  Logger.log('Starting sheet initialization...');
  
  // Create Users sheet
  const usersSheet = getOrCreateSheet(USERS_SHEET, [
    'uid',           // شناسه یکتا کاربر
    'name',          // نام و نام خانوادگی
    'username',      // نام کاربری
    'password',      // رمز عبور
    'role',          // نقش: admin یا employee
    'push_token'     // توکن نوتیفیکیشن
  ]);
  
  // Create default admin user if not exists
  if (usersSheet.getLastRow() === 1) {
    usersSheet.appendRow([
      Utilities.getUuid(),
      'مدیر سیستم',
      'admin',
      'admin123',
      'admin',
      ''
    ]);
    Logger.log('Default admin user created');
  }
  
  // Create Tasks sheet
  getOrCreateSheet(TASKS_SHEET, [
    'task_id',       // شناسه یکتا تسک
    'title',         // عنوان تسک
    'description',   // توضیحات تسک
    'assigned_to',   // uid کارمندی که تسک به او اختصاص داده شده
    'status',        // وضعیت: pending, in_progress, completed
    'created_at',    // تاریخ ایجاد
    'deadline'       // مهلت انجام
  ]);
  
  // Create Checklist sheet
  getOrCreateSheet(CHECKLIST_SHEET, [
    'id',            // شناسه یکتا آیتم چک لیست
    'employee_uid',  // uid کارمند
    'title',         // عنوان آیتم
    'description',   // توضیحات
    'is_completed',  // آیا تکمیل شده: true یا false
    'created_at',    // تاریخ ایجاد
    'completed_at'   // تاریخ تکمیل
  ]);
  
  Logger.log('All sheets initialized successfully!');
  
  return ContentService.createTextOutput(
    'تمام sheet‌ها با موفقیت ایجاد شدند:\n' +
    '✓ Users (کاربران)\n' +
    '✓ Tasks (وظایف)\n' +
    '✓ Checklist (چک لیست‌های شخصی)\n\n' +
    'حالا می‌توانید Web App را Deploy کنید.'
  ).setMimeType(ContentService.MimeType.TEXT);
}

// Main doPost handler
function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    const action = data.action || e.parameter.action;
    
    switch(action) {
      case 'login':
        return login(data);
      case 'createUser':
        return createUser(data);
      case 'createTask':
        return createTask(data);
      case 'updateTaskStatus':
        return updateTaskStatus(data);
      case 'createChecklistItem':
        return createChecklistItem(data.data);
      case 'updateChecklistItem':
        return updateChecklistItem(data.data);
      case 'deleteChecklistItem':
        return deleteChecklistItem(data.itemId);
      default:
        return response(false, 'Invalid action');
    }
  } catch (error) {
    return response(false, error.toString());
  }
}

// Main doGet handler
function doGet(e) {
  try {
    const action = e.parameter.action;
    
    switch(action) {
      case 'getEmployees':
        return getEmployees();
      case 'getAllTasks':
        return getAllTasks();
      case 'getTasksByEmployee':
        return getTasksByEmployee(e.parameter.uid);
      case 'getChecklist':
        return getChecklist(e.parameter.employeeUid);
      default:
        return response(false, 'Invalid action');
    }
  } catch (error) {
    return response(false, error.toString());
  }
}

// Response helper
function response(success, data, message) {
  const output = {
    success: success
  };
  
  if (success) {
    Object.assign(output, data);
  } else {
    output.error = data;
  }
  
  return ContentService.createTextOutput(JSON.stringify(output))
    .setMimeType(ContentService.MimeType.JSON);
}

// Authentication
function login(data) {
  const sheet = getOrCreateSheet(USERS_SHEET, ['uid', 'name', 'username', 'password', 'role', 'push_token']);
  const values = sheet.getDataRange().getValues();
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][2] === data.username && values[i][3] === data.password) {
      const user = {
        uid: values[i][0],
        name: values[i][1],
        username: values[i][2],
        password: values[i][3],
        role: values[i][4],
        push_token: values[i][5]
      };
      return response(true, { user: user });
    }
  }
  
  return response(false, 'Invalid credentials');
}

// Create User
function createUser(data) {
  const sheet = getOrCreateSheet(USERS_SHEET, ['uid', 'name', 'username', 'password', 'role', 'push_token']);
  
  sheet.appendRow([
    data.uid,
    data.name,
    data.username,
    data.password,
    data.role,
    data.push_token || ''
  ]);
  
  return response(true, { message: 'User created successfully' });
}

// Get Employees
function getEmployees() {
  const sheet = getOrCreateSheet(USERS_SHEET, ['uid', 'name', 'username', 'password', 'role', 'push_token']);
  const values = sheet.getDataRange().getValues();
  const users = [];
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][4] === 'employee') {
      users.push({
        uid: values[i][0],
        name: values[i][1],
        username: values[i][2],
        password: values[i][3],
        role: values[i][4],
        push_token: values[i][5]
      });
    }
  }
  
  return response(true, { users: users });
}

// Create Task
function createTask(data) {
  const sheet = getOrCreateSheet(TASKS_SHEET, ['task_id', 'title', 'description', 'assigned_to', 'status', 'created_at', 'deadline']);
  
  sheet.appendRow([
    data.task_id,
    data.title,
    data.description,
    data.assigned_to,
    data.status,
    data.created_at,
    data.deadline
  ]);
  
  return response(true, { message: 'Task created successfully' });
}

// Get All Tasks
function getAllTasks() {
  const sheet = getOrCreateSheet(TASKS_SHEET, ['task_id', 'title', 'description', 'assigned_to', 'status', 'created_at', 'deadline']);
  const values = sheet.getDataRange().getValues();
  const tasks = [];
  
  for (let i = 1; i < values.length; i++) {
    tasks.push({
      task_id: values[i][0],
      title: values[i][1],
      description: values[i][2],
      assigned_to: values[i][3],
      status: values[i][4],
      created_at: values[i][5],
      deadline: values[i][6]
    });
  }
  
  return response(true, { tasks: tasks });
}

// Get Tasks By Employee
function getTasksByEmployee(uid) {
  const sheet = getOrCreateSheet(TASKS_SHEET, ['task_id', 'title', 'description', 'assigned_to', 'status', 'created_at', 'deadline']);
  const values = sheet.getDataRange().getValues();
  const tasks = [];
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][3] === uid) {
      tasks.push({
        task_id: values[i][0],
        title: values[i][1],
        description: values[i][2],
        assigned_to: values[i][3],
        status: values[i][4],
        created_at: values[i][5],
        deadline: values[i][6]
      });
    }
  }
  
  return response(true, { tasks: tasks });
}

// Update Task Status
function updateTaskStatus(data) {
  const sheet = getOrCreateSheet(TASKS_SHEET, ['task_id', 'title', 'description', 'assigned_to', 'status', 'created_at', 'deadline']);
  const values = sheet.getDataRange().getValues();
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][0] === data.task_id) {
      sheet.getRange(i + 1, 5).setValue(data.status);
      return response(true, { message: 'Task status updated successfully' });
    }
  }
  
  return response(false, 'Task not found');
}

// ==================== CHECKLIST FUNCTIONS ====================

// Create Checklist Item
function createChecklistItem(data) {
  const sheet = getOrCreateSheet(CHECKLIST_SHEET, ['id', 'employee_uid', 'title', 'description', 'is_completed', 'created_at', 'completed_at']);
  
  sheet.appendRow([
    data.id,
    data.employee_uid,
    data.title,
    data.description || '',
    data.is_completed || 'false',
    data.created_at,
    data.completed_at || ''
  ]);
  
  return response(true, { message: 'Checklist item created successfully' });
}

// Get Checklist by Employee
function getChecklist(employeeUid) {
  const sheet = getOrCreateSheet(CHECKLIST_SHEET, ['id', 'employee_uid', 'title', 'description', 'is_completed', 'created_at', 'completed_at']);
  const values = sheet.getDataRange().getValues();
  const items = [];
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][1] === employeeUid) {
      items.push({
        id: values[i][0],
        employee_uid: values[i][1],
        title: values[i][2],
        description: values[i][3],
        is_completed: values[i][4],
        created_at: values[i][5],
        completed_at: values[i][6]
      });
    }
  }
  
  return response(true, { data: items });
}

// Update Checklist Item
function updateChecklistItem(data) {
  const sheet = getOrCreateSheet(CHECKLIST_SHEET, ['id', 'employee_uid', 'title', 'description', 'is_completed', 'created_at', 'completed_at']);
  const values = sheet.getDataRange().getValues();
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][0] === data.id) {
      sheet.getRange(i + 1, 3).setValue(data.title);
      sheet.getRange(i + 1, 4).setValue(data.description || '');
      sheet.getRange(i + 1, 5).setValue(data.is_completed);
      sheet.getRange(i + 1, 7).setValue(data.completed_at || '');
      return response(true, { message: 'Checklist item updated successfully' });
    }
  }
  
  return response(false, 'Checklist item not found');
}

// Delete Checklist Item
function deleteChecklistItem(itemId) {
  const sheet = getOrCreateSheet(CHECKLIST_SHEET, ['id', 'employee_uid', 'title', 'description', 'is_completed', 'created_at', 'completed_at']);
  const values = sheet.getDataRange().getValues();
  
  for (let i = 1; i < values.length; i++) {
    if (values[i][0] === itemId) {
      sheet.deleteRow(i + 1);
      return response(true, { message: 'Checklist item deleted successfully' });
    }
  }
  
  return response(false, 'Checklist item not found');
}
