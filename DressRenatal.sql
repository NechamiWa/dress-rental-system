--פרוייקט נחמי ולדנברג ושני פרוינד
--יצירת מסד נתונים להשכרת שמלות

--טבלת דגמים
create table IModels
(
modelCode int primary key identity(1,1),
modelName varchar(20) 
)

--טבלת שמלות
create table IDresses
(
   dressCode int primary key identity(10,1),
   modelCode int foreign key references IModels(modelCode) , 
   dressSize int check(dressSize between 1 and 50)
)

--טבלת לקוחות
create table ICustomers
(
customerCode int primary key identity(1000,1),
customerName varchar(50),
customerAddress varchar(50),
customerPhone varchar,
customerEmail varchar(25)  default 'none'
)

alter table ICustomers
alter column customerPhone varchar(10)

alter table ICustomers
add constraint CHK_CustomerPhone check (LEN(customerPhone) between 9 and 10);

--טבלת השכרות
create table IRents
(
rentCode int primary key identity(100,1),
customerCode int foreign key references ICustomers(customerCode),
rentDate date,
returnDate date,
isReturned bit default 0
)

--טבלת פרטי השכרות
create table IRentsDetails
(
rentCode int foreign key references IRents(rentCode),
dressCode int foreign key references IDresses(dressCode)
)

insert into IModels(modelName)
values('Madrid')

delete from IModels 
where modelName='Madrid'

--פרוצדורה שמקבלת שם לקוח ומעדכנת שהחזיר שמלה
create procedure updateReturn(@customerName varchar(20))
as
begin
	update IRents
	SET isReturned = 1
	WHERE IRents.customerCode=(SELECT ICustomers.customerCode
	FROM ICustomers INNER JOIN
     	IRents ON ICustomers.customerCode = IRents.customerCode
	where ICustomers.customerName=@customerName)
end

exec updateReturn 'Shani'

--פרוצדורה שמוסיפה ליין חדש של שמלות
create procedure addDressLine(@modelName varchar(20),@minSize int,@maxSize int)
as
begin
	--הוספת דגם חדש
	insert into IModels(modelName) values (@modelName)
	--מציאת הקוד שהתווסף
	declare @modelCode int
	select @modelCode=(modelCode)
	from IModels
	where modelName=@modelName
	--יצירת ליין השמלות מהמידה המינימלית למקסימלית
	while(@minSize<=@maxSize)
	begin
		--הוספת שמלה לטבלת השמלות
		insert into IDresses(modelCode,dressSize)
		values(@modelCode,@minSize)
		set @minSize=@minSize+2
	end
end

exec addDressLine 'France',32,40

--פרוצדורה שמקבלת שם לקוח ומציגה את פרטי ההשכרה שלו
alter procedure rentDetails(@customerName varchar(20))
as
begin
SELECT IRents.rentDate, IRents.returnDate,IRents.isReturned
FROM IRents INNER JOIN
IRentsDetails ON IRents.rentCode = IRentsDetails.rentCode
where IRents.customerCode=
	(--מציאת קוד הלקוח שהתקבל
	SELECT ICustomers.customerCode
	FROM ICustomers INNER JOIN
	IRents ON ICustomers.customerCode = IRents.customerCode
	where ICustomers.customerName=@customerName)
end

exec rentDetails 'Nechami'

--פונקציה שמציגה את מספר השמלות לכל לקוח
create procedure howManyDressesForEachCustomer
as
begin
	SELECT ICustomers.customerName,count(IRentsDetails.dressCode)
	FROM ICustomers INNER JOIN
	IRents ON ICustomers.customerCode = IRents.customerCode INNER JOIN
	IRentsDetails ON IRents.rentCode = IRentsDetails.rentCode
	group by ICustomers.customerName
end

exec howManyDressesForEachCustomer 

--פרוצדורה שבודקת האם קיימת שמלה במידה מסויימת
create procedure isExistDress(@modelName varchar(20), @dressSize int)
as
begin
	-- מציאת קוד דגם
	declare @modelCode int
	select @modelCode = modelCode
	from IModels
	where modelName = @modelName
	
	-- מציאת קוד שמלה
	declare @dressCode int
	select @dressCode = dressCode
	from IDresses 
	where modelCode = @modelCode and dressSize = @dressSize
	
	-- בדיקה האם השמלה קיימת
	if @dressCode is not null
	begin
		-- בדיקה האם השמלה מושכרת
		if exists (select dressCode from IRentsDetails where dressCode = @dressCode)
			print 'The dress is rented'
		else
			print 'The dress can be rented'
	end
	else
		print 'The dress is not in stock'
end

exec isExistDress 'Queen',36

--פרוצדורה שמקבלת שם לקוח ובודקת אם הוא קיים
create procedure isCustomerExist(@customerName varchar(20)) 
as
begin
	if exists(SELECT customerCode
	FROM ICustomers
	where customerName=@customerName)
	print 'This customer is exist'
	else
	print 'This customer is not exist'
end
	
exec isCustomerExist 'uuu'

--פרוצדורה שמחזירה כמות ימים שנותרו עד לתאריך ההחזרה
alter procedure returnDays(@customerName varchar(20))
as
begin
	SELECT datediff(DAY ,IRents.rentDate, IRents.returnDate)
	FROM ICustomers INNER JOIN
	IRents ON ICustomers.customerCode = IRents.customerCode
	where ICustomers.customerName=@customerName
end

exec returnDays 'Shani'

--פרוצדורה שמחזירה כמה לקוחות יש
create procedure howManyCustomers
as
begin
SELECT count(customerCode)
FROM ICustomers
end

exec howManyCustomers

--יצירת פונקציה שימושית שתציג את פרטי ההשכרות
create view DressRentalsView
AS
SELECT IRents.rentCode, ICustomers.customerName, ICustomers.customerPhone, ICustomers.customerEmail, IRents.rentDate, IRents.returnDate, IRents.isReturned, IModels.modelName, IDresses.dressSize
FROM IRents
INNER JOIN ICustomers ON IRents.customerCode = ICustomers.customerCode
INNER JOIN IRentsDetails ON IRents.rentCode = IRentsDetails.rentCode
INNER JOIN IDresses ON IRentsDetails.dressCode = IDresses.dressCode
INNER JOIN IModels ON IDresses.modelCode = IModels.modelCode;

SELECT *
FROM DressRentalsView
WHERE customerName = 'Nechami';

--יצירת אינדקס לחיפוש מהיר
CREATE INDEX idx_customerName ON ICustomers (customerName);

--טריגר למניעת הכנסת השכרות עם תאריכי החזרה לפני מועד ההשכרה
CREATE TRIGGER tr_prevent_invalid_rentals
ON IRents
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE returnDate < rentDate)
    BEGIN
        RAISERROR('Cannot insert rentals with return dates before rental dates.', 16, 1)
        ROLLBACK TRANSACTION
    END
END

INSERT INTO IRents (  customerCode, rentDate, returnDate)
VALUES (  '1001', '2022-01-01', '2021-12-31')
 
 --טריגר שמודיע על לקוח חדש
 CREATE TRIGGER showWelcomeMessage
ON ICustomers
AFTER  INSERT
AS
print 'new customer, welcome to our rental!'

insert into ICustomers (customerName ) values ('gili')

