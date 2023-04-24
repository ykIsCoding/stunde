enum userDatabaseKeys {
  ID,
  NAME,
  COMPANY,
  STATUS,
  PAY_RATE,
  EMAIL,
  POSITION,
  SIGNATURE,
  BANK,
  BANK_NUMBER,
}

enum userRecordsDatabaseKeys {
  START_TIME,
  HOURS,
  END_TIME,
  ID,
  BREAK_HOURS,
  REMARKS,
  CLAIM_AMOUNT,
  TYPE,
  RECEIPT_IMAGE
}

Map<userDatabaseKeys, String> userTableKeys = {
  userDatabaseKeys.COMPANY: 'company',
  userDatabaseKeys.EMAIL: 'email',
  userDatabaseKeys.ID: 'id',
  
  userDatabaseKeys.NAME: 'name',
  userDatabaseKeys.PAY_RATE: 'pay_rate',
  userDatabaseKeys.STATUS: 'status',
  userDatabaseKeys.POSITION: 'position',
  userDatabaseKeys.SIGNATURE: 'signature',
  userDatabaseKeys.BANK:'bank',
  userDatabaseKeys.BANK_NUMBER:'bank_number',
};

Map<userRecordsDatabaseKeys, String> userRecordsTableKeys = {
  userRecordsDatabaseKeys.ID: 'id',
  userRecordsDatabaseKeys.START_TIME: 'start_time',
  userRecordsDatabaseKeys.END_TIME: 'end_time',
  userRecordsDatabaseKeys.BREAK_HOURS: 'break_hours',
  userRecordsDatabaseKeys.CLAIM_AMOUNT: 'claim_amount',
  userRecordsDatabaseKeys.REMARKS: 'remarks',
  userRecordsDatabaseKeys.TYPE: 'type',
  userRecordsDatabaseKeys.HOURS: 'hours',
  userRecordsDatabaseKeys.RECEIPT_IMAGE: 'receipt_image'
};
