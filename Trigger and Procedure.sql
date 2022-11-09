/*
 * Creating table account 
 */
create table Account(AccountNumber int primary key auto_increment, 
CustomerName varchar(30) not null, 
Balance numeric(10,2));


/*
 * Creating table account_update 
 */
create table account_update(accountNumber int,
CustomerName varchar(30) not null,
changed_id timestamp,
old_balance numeric(10,2) not null,
transaction_amount numeric(10,2) not null,
transactionType varchar(30) not null,
new_balance numeric(10,2) not null);

/*
 * Inserting into account
 */
insert into account(CustomerName,balance) values("Sanjay",40000);
insert into account(CustomerName,balance) values("Sushanth",50000);

/*
 * Creating trigger for debit type of transaction
 */
delimiter **
 create trigger account_update_debit  before update on account for each row
 begin
 if(old.balance>new.balance) then
    insert into account_update(accountNumber,customerName,changed_id,transactionType, old_balance ,new_balance,transaction_amount)
    values(old.accountNumber,old.customerName, now(),'debit', old.balance, new.balance, old.balance-new.balance);
    END IF;
end**

/*
 * to drop trigger account_update_ddebit
 */
drop trigger account_update_debit

/*
 * creating trigger for credit type of transaction
 */
delimiter !!
 create trigger account_update_credit  before update on account for each row
 begin
 if(old.balance<new.balance) then
    insert into account_update(accountNumber,customerName,changed_id,transactionType, old_balance ,new_balance, transaction_amount)
    values(old.accountNumber,old.customerName, now(),'credit', old.balance, new.balance, new.balance-old.balance);
    END IF;
end!!

/*
 * to drop trigger account_update_credit
 */
drop trigger account_update_credit

/*
 * Updating balance in account
 */
update account set balance=balance-4000 where accountNumber=1;
update account set balance=balance+6000 where accountNumber=1

/*
 * Creating Procedureto get the Sum of withdrawal and deposit;
 */
delimiter %%
create procedure sumWithdrawal(in acc_No int, out totalDebit numeric(10,2), out totalCredit numeric(10,2))
begin
select sum(old_balance-new_balance) into totalDebit from account_update where  transactionType='debit' and accountNumber=acc_No;
select sum(new_balance-old_balance) into totalCredit from account_update where  transactionType='credit' and accountNumber=acc_No;
end %%

/*
 * for dropping the procedure
 */
drop procedure sumWithdrawal;

call sumWithdrawal(1, @totalDebit,@totalCredit);

select @totalDebit,@totalCredit;

CREATE EVENT FirstEvent
    ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 HOUR
    DO
      CALL sumWithdrawal(1, @totalDebit,@totalCredit);
      
    DROP EVENT FirstEvent;