CREATE DATABASE [DevDB2022-py2-viklit];
GO

USE [DevDB2022-py2-viklit];
GO

SET XACT_ABORT ON
GO

CREATE SCHEMA bookkeeping;
GO
CREATE SCHEMA equipment;
GO
CREATE SCHEMA engeneering;
GO
CREATE SCHEMA maintenance;
GO
CREATE SCHEMA hr;
GO
CREATE SCHEMA fabrication;
GO
CREATE SCHEMA operator;
GO

CREATE TABLE equipment.supply_catalog (
	supplycatid int IDENTITY(1, 1) PRIMARY KEY,
	catpositionname nvarchar(50) NOT NULL UNIQUE,
	catnumber nvarchar(20) NOT NULL UNIQUE,
	catitemprice smallmoney NULL
);
GO

CREATE TABLE hr.subdivision (
	subdid smallint IDENTITY(1, 1) PRIMARY KEY,
	subdivisionname nvarchar(30) NOT NULL UNIQUE,
	subdfunctions nvarchar(300) NULL
);
GO

CREATE TABLE fabrication.cat_additional_services (
	catadditionalid smallint IDENTITY(1, 1) PRIMARY KEY,
	catadditionalname nvarchar(100) NOT NULL UNIQUE,
	catadditionalprice smallmoney NOT NULL
);
GO

CREATE TABLE engeneering.prod_plan (
	planid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	plandesc nvarchar(100) NOT NULL UNIQUE,
	startingdate smalldatetime NOT NULL DEFAULT GETDATE(),
	nominaltempdate smalldatetime NOT NULL,
	completiondate smalldatetime NOT NULL
);
GO

CREATE TABLE bookkeeping.cat_fixed_costs (
	fixcostcatid smallint IDENTITY(1, 1) PRIMARY KEY,
	fixcostcatname varchar(15) NOT NULL UNIQUE,
	priceperone smallmoney NOT NULL
);
GO

CREATE TABLE hr.employees (
	pnum uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	subdivisionid smallint NOT NULL,
	reqid smallint NOT NULL, -- Ссылка на реквизиты банка
	lastname nvarchar(20) NOT NULL,
	firstname nvarchar(20) NOT NULL,
	patronymic nvarchar(20) NOT NULL,
	birthdate date NOT NULL,
	passport nvarchar(10) NOT NULL UNIQUE,
	snils nvarchar(14) NOT NULL UNIQUE,
	employmentdate date NOT NULL DEFAULT GETDATE(),
	dismissaldate date NULL DEFAULT NULL,
	leadid uniqueidentifier NULL DEFAULT NULL,
	salary smallmoney NOT NULL,
	bank_acс nvarchar(20) NOT NULL UNIQUE, -- Номер счёта в банке
	CONSTRAINT bank_account CHECK 
	(bank_acс LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CONSTRAINT passport_field CHECK (passport LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CONSTRAINT snils_field CHECK (snils LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9]'),
	FOREIGN KEY (leadid) REFERENCES hr.employees (pnum)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (subdivisionid) REFERENCES hr.subdivision (subdid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE bookkeeping.requisites (
	reqid smallint IDENTITY(1, 1) PRIMARY KEY,
	fullbankname nvarchar(300) NOT NULL UNIQUE,
	shortbankname nvarchar(150) NOT NULL UNIQUE,
	email nvarchar(50) NOT NULL,
	[k-order] nvarchar(120) NOT NULL,
	BIK nvarchar(10) NOT NULL,
	INN nvarchar(10) NOT NULL,
	KPP nvarchar(9) NOT NULL,
	OGRN nvarchar(13) NOT NULL,
	SWIFT nvarchar(30) NOT NULL,
	CHECK (email LIKE '%@%.%'),
	CHECK ([k-order] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'),
	CHECK (BIK LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CHECK (INN LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CHECK (KPP LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CHECK (OGRN LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO

ALTER TABLE hr.employees
	ADD FOREIGN KEY (reqid) REFERENCES bookkeeping.requisites (reqid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;
GO

CREATE TABLE bookkeeping.customers (
	custid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	requsitesid smallint NOT NULL,
	custname nvarchar(100) NOT NULL UNIQUE,
	legaladress varchar(200) NOT NULL,
	factadress varchar(200) NOT NULL,
	contactperson nvarchar(20),
	tel nvarchar(15) NOT NULL,
	email varchar(50) NOT NULL,
	CHECK (tel LIKE '[0-9]-[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
	CHECK (email LIKE '%@%.%'),
	FOREIGN KEY (requsitesid) REFERENCES bookkeeping.requisites (reqid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE bookkeeping.income_statement (
	indocn uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	requisitesid smallint NOT NULL,
	dealid uniqueidentifier NOT NULL,
	inflow money NOT NULL,
	note nvarchar(175) NOT NULL,
	deletion money NOT NULL,
	[date] datetime NOT NULL,
	total AS inflow - deletion,
	FOREIGN KEY (requisitesid) REFERENCES bookkeeping.requisites (reqid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE fabrication.machines (
	machinename nvarchar(15) PRIMARY KEY,
	scheduledstopdate date NULL DEFAULT NULL,
	specification nvarchar(20) NOT NULL,
	ismachineinwork bit NOT NULL DEFAULT 1,
	oilfillingdate date NULL DEFAULT NULL,
	conecleaningdate date NULL DEFAULT NULL,
	backlashcompensationsetdate date NULL DEFAULT NULL,
);
GO

CREATE UNIQUE INDEX machineid ON fabrication.machines (machinename);
GO

CREATE TABLE maintenance.[service] (
	srvid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	machine nvarchar(15) NOT NULL,
	spec uniqueidentifier NOT NULL,
	cause nvarchar(300) NOT NULL,
	[date] date NOT NULL,
	partsunderrepair nvarchar(200) NULL
	FOREIGN KEY (machine) REFERENCES fabrication.machines (machinename)
	ON DELETE CASCADE
	ON UPDATE NO ACTION,
	FOREIGN KEY (spec) REFERENCES hr.employees (pnum)
	ON DELETE NO ACTION
	ON UPDATE CASCADE
);
GO

CREATE TABLE fabrication.locksmith (
	lckwid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	item uniqueidentifier NOT NULL,
	[date] date NOT NULL
); 
GO

CREATE TABLE fabrication.production (
	detid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	custid uniqueidentifier NOT NULL,
	otkid uniqueidentifier NULL,
	[name] nvarchar(50) NOT NULL,
	[type] nvarchar(50) NOT NULL,
	arrivaldate date NOT NULL, -- Прибытие детали на завод
	until date NULL, -- Предельный срок сдачи
	contractdate date NOT NULL, -- Рассчётный срок сдачи
	factdate date NULL, -- Фактический срок сдачи
	note nvarchar(100) NULL,
	contractprice smallmoney NOT NULL,
	isdiscard bit NOT NULL DEFAULT 0
	FOREIGN KEY (custid) REFERENCES bookkeeping.customers (custid)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
GO

ALTER TABLE fabrication.locksmith
ADD FOREIGN KEY (item) REFERENCES fabrication.production (detid)

CREATE TABLE engeneering.quality_control (
	otkid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	prodid uniqueidentifier NOT NULL,
	isinclearance bit NOT NULL,
	price smallmoney NOT NULL,
	[date] date NOT NULL,
	[sample] image NOT NULL -- выбрал бы filestream
	FOREIGN KEY (prodid) REFERENCES fabrication.production (detid)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
GO

CREATE TABLE operator.operators_monthly_schedule (
	mtabid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	oid uniqueidentifier NOT NULL,
	[date] date NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (oid) REFERENCES hr.employees (pnum)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
GO

CREATE FUNCTION count_total_hours(@month_tab uniqueidentifier)
RETURNS float
BEGIN
DECLARE @total float
SELECT @total=SUM([hours])
FROM operator.operator_day_time_sheet
WHERE munthlytabid=@month_tab
RETURN @total
END;
GO

ALTER TABLE operator.operators_monthly_schedule
	ADD total AS dbo.count_total_hours(mtabid);
GO

-- Если оператор добавляет в табель день, то нужно проверить уникальность этой даты для этого оператора
CREATE FUNCTION check_unique_date(@operator uniqueidentifier, @d date)
RETURNS bit
BEGIN
	DECLARE @i smallint
	SELECT @i=COUNT(dtabid)
	FROM operator.operator_day_time_sheet
	WHERE oid=@operator AND [date]=@d
	IF @i>1
		RETURN '1'
	RETURN '0'
END;
GO

-- Если оператор добавляет в табель день, то нужно убедиться, что день принадлежит текущему году и месяцу
CREATE FUNCTION check_month_and_year(@operator uniqueidentifier, @d date)
RETURNS bit
BEGIN
	DECLARE @counter smallint
	SELECT @counter=COUNT(mtabid)
	FROM operator.operators_monthly_schedule
	WHERE oid=@operator AND YEAR([date])=YEAR(@d) AND MONTH([date])=MONTH(@d)
	IF @counter>0
		RETURN '1'
	RETURN '0'
END;
GO

-- Если оператор добавляет в табель день, то нужно убедиться, что этот день уже "отработан"
CREATE FUNCTION check_timeliness(@d date)
RETURNS bit
BEGIN
	IF DAY(@d)>DAY(GETDATE())
		RETURN '0'
	RETURN '1'
END;
GO

CREATE TABLE operator.operator_day_time_sheet (
	dtabid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	oid uniqueidentifier NOT NULL,
	munthlytabid uniqueidentifier NOT NULL,
	[date] date NOT NULL DEFAULT GETDATE(),
	[hours] float NOT NULL,
	CHECK([hours]<='24.0'),
	CONSTRAINT check_unique_day CHECK(dbo.check_unique_date(oid, [date])=0),
	CONSTRAINT day_and_year_in_current_month CHECK(dbo.check_month_and_year(oid, [date])=1),
	CONSTRAINT timeliness CHECK(dbo.check_timeliness([date])=1),
	FOREIGN KEY (oid) REFERENCES hr.employees (pnum)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY (munthlytabid) REFERENCES operator.operators_monthly_schedule (mtabid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO


CREATE TRIGGER operator.monthly_schedule
ON operator.operators_monthly_schedule FOR INSERT
AS
BEGIN
	DECLARE @tab_id uniqueidentifier
	DECLARE @counter smallint
	SELECT @counter=COUNT(inserted.mtabid)
	FROM operator.operators_monthly_schedule AS all_t
	INNER JOIN inserted
	ON all_t.oid=inserted.oid
	WHERE MONTH(all_t.[date])=MONTH(GETDATE())
	IF @counter>1
		BEGIN
			ROLLBACK TRANSACTION
			PRINT N'Табель оператора должен быть уникальным для каждого сотрудника в течение одного месяца'
		END
END;
GO

CREATE TABLE bookkeeping.selling (
	saleid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	custid uniqueidentifier NOT NULL,
	prodid uniqueidentifier NOT NULL,
	[date] smalldatetime NOT NULL,
	FOREIGN KEY (custid) REFERENCES bookkeeping.customers (custid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY (prodid) REFERENCES fabrication.production (detid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE equipment.supply (
	supplyid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	catid int NOT NULL,
	pnum uniqueidentifier NOT NULL,
	note nvarchar(50) NOT NULL,
	qty smallint NOT NULL,
	[status] bit NOT NULL DEFAULT 0,
	[date] smalldatetime NOT NULL,
	FOREIGN KEY (catid) REFERENCES equipment.supply_catalog (supplycatid)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
GO

CREATE FUNCTION sum_supply()
RETURNS smallmoney
BEGIN
	DECLARE @total smallmoney
	DECLARE @id int
	DECLARE @count smallint
	SELECT @id=catid, @count=qty
	FROM equipment.supply
	SELECT @total=SUM(catitemprice * @count)
	FROM equipment.supply_catalog
	WHERE supplycatid=@id
	RETURN @total
END;
GO

ALTER TABLE equipment.supply
ADD total AS dbo.sum_supply();
GO

CREATE FUNCTION get_all_services(@id smallint)
RETURNS smallmoney
BEGIN
	DECLARE @total_price smallmoney
	SELECT @total_price=SUM(catadditionalprice)
	FROM fabrication.cat_additional_services
	WHERE catadditionalid=@id
	RETURN @total_price
END;
GO

CREATE TABLE fabrication.additional_services (
	aserviceid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	prodid uniqueidentifier NOT NULL,
	srvcatid smallint NOT NULL,
	total AS dbo.get_all_services(srvcatid),
	FOREIGN KEY (prodid) REFERENCES fabrication.production (detid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	FOREIGN KEY (srvcatid) REFERENCES fabrication.cat_additional_services (catadditionalid)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);
GO

CREATE TABLE engeneering.technological_docs (
	projectid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	prodid uniqueidentifier NOT NULL,
	draw image NOT NULL, -- выбрал бы filestream
	model image NOT NULL, -- выбрал бы filestream
	set_chart image NOT NULL, -- выбрал бы filestream
	devdate smalldatetime NOT NULL,
	note nvarchar(100) NULL,
	worktype bit NOT NULL, -- Изготовление/Ремонт(восстановление) 
	FOREIGN KEY (prodid) REFERENCES fabrication.production (detid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE engeneering.development (
	CONSTRAINT devid PRIMARY KEY CLUSTERED (prodid, engeneer, techprocessid),
	prodid uniqueidentifier NOT NULL,
	engeneer uniqueidentifier NOT NULL,
	techprocessid uniqueidentifier NOT NULL,
	[date] date NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (prodid) REFERENCES fabrication.production (detid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (engeneer) REFERENCES hr.employees (pnum)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE bookkeeping.additional_cost_sheet (
	additioncostid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	supply uniqueidentifier NULL DEFAULT NULL,
	servicesid uniqueidentifier NULL DEFAULT NULL,
	otk uniqueidentifier NULL DEFAULT NULL,
	[date] smalldatetime NOT NULL,
	[status] bit NOT NULL DEFAULT 0,
	FOREIGN KEY (supply) REFERENCES equipment.supply (supplyid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (servicesid) REFERENCES fabrication.additional_services (aserviceid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (otk) REFERENCES engeneering.quality_control (otkid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE FUNCTION count_total_additional_cost_sheet(@supply uniqueidentifier, @srv uniqueidentifier, @otk uniqueidentifier)
RETURNS smallmoney
BEGIN
DECLARE @total smallmoney
	IF @supply IS NOT NULL
		SELECT @total=total
		FROM equipment.supply
		WHERE supplyid=@supply
	IF @srv IS NOT NULL
		SELECT @total=total
		FROM fabrication.additional_services
		WHERE aserviceid=@srv
	IF @otk IS NOT NULL
		SELECT @total=price
		FROM engeneering.quality_control
		WHERE otkid=@otk
RETURN @total
END;
GO

ALTER TABLE bookkeeping.additional_cost_sheet
ADD total AS dbo.count_total_additional_cost_sheet(supply, servicesid, otk);
GO

CREATE TRIGGER bookkeeping.additional_cost_insert
ON bookkeeping.additional_cost_sheet FOR INSERT
AS
BEGIN
	DECLARE @counter smallint
	SET @counter=0
	DECLARE @costid uniqueidentifier
	DECLARE @spplyid uniqueidentifier
	DECLARE @srvid uniqueidentifier
	DECLARE @otkid uniqueidentifier

	SELECT @costid=additioncostid, @spplyid=supply, @srvid=servicesid, @otkid=otk
	FROM inserted
	IF @spplyid IS NOT NULL
		SET @counter+=1
	IF @srvid IS NOT NULL
		SET @counter+=1
	IF @otkid IS NOT NULL
		SET @counter+=1
	IF @counter<1
		BEGIN
			ROLLBACK TRANSACTION
			PRINT N'Одно из значений полей с внешними ключами должно быть NOT NULL'
		END
	IF @counter>1
		BEGIN
			ROLLBACK TRANSACTION
			PRINT N'Только одно значение полей с внешним ключом может быть NOT NULL'
		END
END;
GO

CREATE TRIGGER bookkeeping.additional_cost_update
ON bookkeeping.additional_cost_sheet FOR UPDATE
AS
BEGIN
IF UPDATE(supply)
	DECLARE @spplyid uniqueidentifier
	SELECT @spplyid=supply
	FROM inserted
	if @spplyid IS NULL
		DELETE FROM equipment.supply WHERE supplyid=@spplyid
IF UPDATE(servicesid)
	DECLARE @srvid uniqueidentifier
	SELECT @srvid=servicesid
	FROM inserted
	if @srvid IS NULL
		DELETE FROM fabrication.additional_services WHERE aserviceid=@srvid
IF UPDATE(otk)
	DECLARE @otkid uniqueidentifier
	SELECT @otkid=otk
	FROM inserted
	if @otkid IS NULL
		DELETE FROM engeneering.quality_control WHERE otkid=@otkid
END;
GO

CREATE TABLE bookkeeping.hourly_payroll (
	hprid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	tabid uniqueidentifier NOT NULL,
	operateid uniqueidentifier NOT NULL,
	[date] date NOT NULL DEFAULT GETDATE(),
	personalincometax smallmoney NOT NULL DEFAULT 0,
	fine smallmoney NOT NULL DEFAULT 0,
	total smallmoney NOT NULL DEFAULT 0,
	FOREIGN KEY (tabid) REFERENCES operator.operators_monthly_schedule (mtabid)
	ON DELETE NO ACTION
	ON UPDATE CASCADE,
	FOREIGN KEY (operateid) REFERENCES hr.employees (pnum)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
);
GO

CREATE TABLE bookkeeping.payroll_sheet (
	tabid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	empid uniqueidentifier NOT NULL,
	[date] date NOT NULL,
	total smallmoney NOT NULL DEFAULT 0,
	personalincometax smallmoney NOT NULL DEFAULT 0,
	fine smallmoney NOT NULL DEFAULT 0,
	FOREIGN KEY (empid) REFERENCES hr.employees (pnum)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE bookkeeping.work_agreement (
	ordid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	empid uniqueidentifier NOT NULL,
	personalincometax smallmoney NOT NULL DEFAULT 0,
	contractdate date NOT NULL,
	until date NOT NULL,
	[text] nvarchar(500) NOT NULL,
	fine smallmoney NOT NULL DEFAULT 0,
	[status] bit DEFAULT 1 NOT NULL,
	FOREIGN KEY (empid) REFERENCES hr.employees (pnum)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE bookkeeping.fixed_cost_statement (
	fixcostid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	catid smallint NOT NULL,
	fixcostnum nvarchar(30) NOT NULL,
	fixcostprice smallmoney NOT NULL,
	[date] date NOT NULL,
	CONSTRAINT fixcostnum_validation CHECK(fixcostnum LIKE '[0-9]'),
	FOREIGN KEY (catid) REFERENCES bookkeeping.cat_fixed_costs (fixcostcatid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);
GO

CREATE TABLE bookkeeping.expense_sheet (
	expid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	hpayroll uniqueidentifier NULL DEFAULT NULL,
	tpayroll uniqueidentifier NULL DEFAULT NULL,
	acostst uniqueidentifier NULL DEFAULT NULL,
	fcostst uniqueidentifier NULL DEFAULT NULL,
	[date] smalldatetime NOT NULL,
	[status] bit NOT NULL DEFAULT 0,
	docnumber nvarchar(100) NOT NULL,
	FOREIGN KEY (hpayroll) REFERENCES bookkeeping.hourly_payroll (hprid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (tpayroll) REFERENCES bookkeeping.payroll_sheet (tabid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (acostst) REFERENCES bookkeeping.additional_cost_sheet (additioncostid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (fcostst) REFERENCES bookkeeping.fixed_cost_statement (fixcostid)
);
GO

CREATE TABLE fabrication.manufacturing (
	unitid uniqueidentifier DEFAULT NEWID() PRIMARY KEY,
	machine nvarchar(15) NULL,
	prodid uniqueidentifier NOT NULL,
	personid uniqueidentifier NOT NULL,
	docsid uniqueidentifier NULL,
	planid uniqueidentifier NOT NULL,
	addid uniqueidentifier NULL,
	locksmithid uniqueidentifier NULL,
	[date] date NOT NULL,
	FOREIGN KEY (machine) REFERENCES fabrication.machines (machinename)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (prodid) REFERENCES fabrication.production (detid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (personid) REFERENCES hr.employees (pnum)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (docsid) REFERENCES engeneering.technological_docs (projectid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (planid) REFERENCES engeneering.prod_plan (planid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (addid) REFERENCES fabrication.additional_services (aserviceid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
	FOREIGN KEY (locksmithid) REFERENCES fabrication.locksmith (lckwid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
);
GO

-- 1 экземпляр ведомости расхода может иметь только один внешний ключ
CREATE TRIGGER bookkeeping.expense_sheet_unique_control_create
ON bookkeeping.expense_sheet FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @counter smallint
	SET @counter=0
	DECLARE @hour_payroll uniqueidentifier
	DECLARE @month_payroll uniqueidentifier
	DECLARE @additional_cost uniqueidentifier
	DECLARE @fixed_payroll uniqueidentifier
	SELECT @hour_payroll=hpayroll, @month_payroll=tpayroll,
	@additional_cost=acostst, @fixed_payroll=fcostst
	FROM inserted
	IF @hour_payroll IS NOT NULL
		SET @counter+=1
	IF @month_payroll IS NOT NULL
		SET @counter+=1
	IF @additional_cost IS NOT NULL
		SET @counter+=1
	IF @fixed_payroll IS NOT NULL
		SET @counter+=1
	IF @counter>1
		ROLLBACK TRANSACTION
END;
GO

-- Запретить продление договора подряда, если предыдущий ещё действует
CREATE TRIGGER bookkeeping.work_agreement_unique_control
ON bookkeeping.work_agreement AFTER INSERT
AS BEGIN
	DECLARE @counter smallint
	DECLARE @current_dte date
	DECLARE @contractdate date
	DECLARE @until date
	SET @current_dte=GETDATE()
	SET @counter=0
	SELECT @contractdate=inserted.contractdate, @until=inserted.until
	FROM inserted
	SELECT @counter=COUNT(all_agreement.ordid)
	FROM bookkeeping.work_agreement AS all_agreement
	INNER JOIN inserted
	ON all_agreement.empid=inserted.empid
	WHERE all_agreement.[status]=1 AND @current_dte BETWEEN @contractdate AND @until
	IF @counter>0
		BEGIN
			ROLLBACK TRANSACTION
			PRINT N'Договор подряда, в указанный период, на данного сотрудника, уже создан'
		END
	IF @current_dte>@contractdate
		BEGIN
			ROLLBACK TRANSACTION
			PRINT N'Запрещено заключать договоры задним числом!'
		END
	IF @until<@contractdate
		BEGIN
			ROLLBACK TRANSACTION
			PRINT N'Дата окончания действия договора раньше, чем дата заключения!'
		END
END;
GO

-- В течение одного месяца доступтимо создать только одну (почасовую) ведомость на 1 работника
CREATE TRIGGER bookkeeping.hourly_payroll_unique_control
ON bookkeeping.hourly_payroll AFTER INSERT
AS BEGIN
	DECLARE @counter smallint
	SELECT @counter=COUNT(sheet.tabid)
	FROM bookkeeping.payroll_sheet AS sheet
	INNER JOIN inserted
	ON inserted.operateid=sheet.empid
	WHERE MONTH(sheet.[date])=MONTH(GETDATE())
	IF @counter>0
		ROLLBACK TRANSACTION
END;
GO

-- В течение одного месяца доступтимо создать только одну (окладную) ведомость на 1 работника
CREATE TRIGGER bookkeeping.payroll_unique_control
ON bookkeeping.payroll_sheet AFTER INSERT
AS BEGIN
	DECLARE @counter smallint
	SELECT @counter=COUNT(sheet.tabid)
	FROM bookkeeping.payroll_sheet AS sheet
	INNER JOIN inserted
	ON inserted.empid=sheet.empid
	WHERE MONTH(sheet.[date])=MONTH(GETDATE())
	IF @counter>1
		ROLLBACK TRANSACTION
END;
GO

-- Вызывать эту функцию из плаировщика по 1 разу ежемесячно в один день
-- Автосоздание почасовой зарплатной  (почасовой) ведомости
CREATE PROCEDURE operator.autocreate_hourly_payroll(@employeer_id uniqueidentifier, @year smallint, @month smallint)
	-- employeer_id - ID оператора, для которого нужно сформировать ведомость
	AS BEGIN
	DECLARE @tab_id uniqueidentifier
	DECLARE @salary smallmoney
	DECLARE @total_hours float(1)
	DECLARE @status bit
	SELECT @tab_id=month_tab.mtabid, @total_hours=month_tab.total, @salary=emp.salary
	FROM hr.employees AS emp
	INNER JOIN operator.operators_monthly_schedule AS month_tab
	ON emp.pnum=month_tab.oid
	WHERE emp.pnum=@employeer_id AND YEAR(month_tab.[date])=@year AND MONTH(month_tab.[date])=@month
	if @total_hours>0
		DECLARE @fine smallmoney
		DECLARE @income_tax smallmoney
		DECLARE @total smallmoney
		SET @fine=@salary * @total_hours
		SET @income_tax=@fine-(@fine*13/100)
		SET @total=@fine-@income_tax
		INSERT INTO bookkeeping.hourly_payroll(tabid, operateid, [date], personalincometax, fine, total) 
		VALUES (@tab_id, @employeer_id, GETDATE(), @income_tax, @fine, @total)
	END;
GO

-- Вызывать эту функцию из плаировщика по 1 разу ежемесячно в один день
-- Автосоздание почасовой зарплатной  (окладной) ведомости
CREATE PROCEDURE operator.autocreate_payroll(@employeer_id uniqueidentifier, @year smallint, @month smallint)
	-- employeer_id - ID оператора, для которого нужно сформировать ведомость
	AS BEGIN
	DECLARE @salary smallmoney
	DECLARE @status bit
	SELECT @salary=emp.salary
	FROM hr.employees AS emp
	WHERE emp.pnum=@employeer_id

	DECLARE @fine smallmoney
	DECLARE @income_tax smallmoney
	DECLARE @total smallmoney
	SET @fine=@salary
	SET @income_tax=@fine-(@fine*13/100)
	SET @total=@fine-@income_tax
	INSERT INTO bookkeeping.payroll_sheet(empid, [date], personalincometax, fine, total) 
	VALUES (@employeer_id, CONVERT(date, CONVERT(nchar, @month)+'-'+CONVERT(nchar, @year)), @income_tax, @fine, @total)
	END;
GO
----------------------------------------- END
---------представления
-- Самая выгодная продукция с точки зрения прибыли и сроков производства
CREATE VIEW fabrication.show_most_profitable_production
AS
SELECT TOP 100 DATEDIFF(minute, contractdate, factdate) AS [Операционное время (МИН)], contractprice AS [стоимость]
FROM fabrication.production
ORDER BY [Операционное время (МИН)], [стоимость] DESC;
GO

-- Лучшие 100 бракоделов за текущий месяц
CREATE VIEW fabrication.most_defect_operators
AS
SELECT TOP 100 emp.lastname AS [Оператор (Фамилия)], COUNT(factory.personid) AS [Количество брака]
FROM fabrication.production AS production
INNER JOIN fabrication.manufacturing AS factory
ON factory.prodid=production.detid
INNER JOIN hr.employees AS emp
ON factory.personid=emp.pnum
GROUP BY detid, machine, isdiscard, emp.lastname, contractdate
HAVING production.isdiscard=1 AND MONTH(contractdate)=MONTH(GETDATE()) AND factory.machine IS NOT NULL
ORDER BY [Количество брака] DESC;
GO