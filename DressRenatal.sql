--������� ���� ������� ���� ������
--����� ��� ������ ������ �����

--���� �����
create table IModels
(
modelCode int primary key identity(1,1),
modelName varchar(20) 
)

--���� �����
create table IDresses
(
   dressCode int primary key identity(10,1),
   modelCode int foreign key references IModels(modelCode) , 
   dressSize int check(dressSize between 1 and 50)
)

--���� ������
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

--���� ������
create table IRents
(
rentCode int primary key identity(100,1),
customerCode int foreign key references ICustomers(customerCode),
rentDate date,
returnDate date,
isReturned bit default 0
)

--���� ���� ������
create table IRentsDetails
(
rentCode int foreign key references IRents(rentCode),
dressCode int foreign key references IDresses(dressCode)
)

insert into IModels(modelName)
values('Madrid')

delete from IModels 
where modelName='Madrid'

--�������� ������ �� ���� ������� ������ ����
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

--�������� ������� ���� ��� �� �����
create procedure addDressLine(@modelName varchar(20),@minSize int,@maxSize int)
as
begin
	--����� ��� ���
	insert into IModels(modelName) values (@modelName)
	--����� ���� �������
	declare @modelCode int
	select @modelCode=(modelCode)
	from IModels
	where modelName=@modelName
	--����� ���� ������ ������ ��������� ���������
	while(@minSize<=@maxSize)
	begin
		--����� ���� ����� ������
		insert into IDresses(modelCode,dressSize)
		values(@modelCode,@minSize)
		set @minSize=@minSize+2
	end
end

exec addDressLine 'France',32,40

--�������� ������ �� ���� ������ �� ���� ������ ���
alter procedure rentDetails(@customerName varchar(20))
as
begin
SELECT IRents.rentDate, IRents.returnDate,IRents.isReturned
FROM IRents INNER JOIN
IRentsDetails ON IRents.rentCode = IRentsDetails.rentCode
where IRents.customerCode=
	(--����� ��� ����� ������
	SELECT ICustomers.customerCode
	FROM ICustomers INNER JOIN
	IRents ON ICustomers.customerCode = IRents.customerCode
	where ICustomers.customerName=@customerName)
end

exec rentDetails 'Nechami'

--������� ������ �� ���� ������ ��� ����
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

--�������� ������ ��� ����� ���� ����� �������
create procedure isExistDress(@modelName varchar(20), @dressSize int)
as
begin
	-- ����� ��� ���
	declare @modelCode int
	select @modelCode = modelCode
	from IModels
	where modelName = @modelName
	
	-- ����� ��� ����
	declare @dressCode int
	select @dressCode = dressCode
	from IDresses 
	where modelCode = @modelCode and dressSize = @dressSize
	
	-- ����� ��� ����� �����
	if @dressCode is not null
	begin
		-- ����� ��� ����� ������
		if exists (select dressCode from IRentsDetails where dressCode = @dressCode)
			print 'The dress is rented'
		else
			print 'The dress can be rented'
	end
	else
		print 'The dress is not in stock'
end

exec isExistDress 'Queen',36

--�������� ������ �� ���� ������ �� ��� ����
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

--�������� ������� ���� ���� ������ �� ������ ������
alter procedure returnDays(@customerName varchar(20))
as
begin
	SELECT datediff(DAY ,IRents.rentDate, IRents.returnDate)
	FROM ICustomers INNER JOIN
	IRents ON ICustomers.customerCode = IRents.customerCode
	where ICustomers.customerName=@customerName
end

exec returnDays 'Shani'

--�������� ������� ��� ������ ��
create procedure howManyCustomers
as
begin
SELECT count(customerCode)
FROM ICustomers
end

exec howManyCustomers

--����� ������� ������� ����� �� ���� �������
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

--����� ������ ������ ����
CREATE INDEX idx_customerName ON ICustomers (customerName);

--����� ������ ����� ������ �� ������ ����� ���� ���� ������
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
 
 --����� ������ �� ���� ���
 CREATE TRIGGER showWelcomeMessage
ON ICustomers
AFTER  INSERT
AS
print 'new customer, welcome to our rental!'

insert into ICustomers (customerName ) values ('gili')

