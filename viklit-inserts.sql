USE [DevDB2022-py2-viklit];
GO

INSERT INTO hr.subdivision(subdivisionname, subdfunctions)
	VALUES (N'Ведущий инженер-программист', N'Согласование доработок с 
	заказчиками. Внесение изменений в модель. Участие в составлении производственного плана. Проектирование и разработка механической обработки, 
	согласно модели и чертежу. Создание УП.'),
	(N'Инженер-программист', N'Проектирование и разработка механической обработки, 
	согласно модели и чертежу. Создание УП.'),
	(N'Оператор 3х осевых станков', N'Написание УП на стойке. 
	Работа на 3-координатных станках, - выполнение операций согласно технологической документации'),
	(N'Оператор 5х осевых станков', N'Написание УП на стойке.)
	Работа на 5-координатных станках, - выполнение операций согласно технологической документации'),
	(N'Начальник производства', N'Обеспечение и контроль производственных процессов. 
	Лицо ответственное за пожарную безопасность, охрану труда.'),
	(N'Главный технолог', N'Начальник технологического отдела. Разработка производственного плана, 
	распределение объёмов работ среди инженеров-программистов. Внедрение новых стратегий обработки.');
GO

INSERT INTO bookkeeping.requisites (fullbankname, shortbankname, email, [k-order], BIK, INN, KPP, OGRN, SWIFT)
	VALUES (
		N'ПУБЛИЧНОЕ АКЦИОНЕРНОЕ ОБЩЕСТВО «БАНК «САНКТ-ПЕТЕРБУРГ»',
		N'ПАО «Банк «Санкт-Петербург»',
		N'info@bspb.ru',
		N'30101810900000000790 Северо-Западное ГУ Банка России',
		N'044030790',
		N'7831000027',
		N'780601001',
		N'1027800000140',
		N'JSBSRU2P');
GO

INSERT INTO hr.employees(reqid, subdivisionid, firstname, lastname, patronymic, birthdate, passport, snils, employmentdate, leadid, salary, bank_acс)
	VALUES ('1', '5', N'Алексей', N'Ни', N'Валерьевич', '1978-01-11', '1036786266', '555-345-022-18', GETDATE(), NULL, '175.00', '09847356729584735074'),
	('1', '6', N'Алексей', N'Арасланов', N'Станиславович', '1981-04-13', '1036786256', '555-345-022-98', GETDATE(), NULL, '130.00', '29847356729584735074'),
	('1', '4', N'Виктор', N'Литовченко', N'Иванович', '1993-07-14', '1035786256', '555-345-022-38', GETDATE(), NULL, '112.00', '29877356729584735074'),
	('1', '4', N'Игорь', N'Сазонов', N'Александрович', '1975-10-21', '1035786251', '555-345-122-12', GETDATE(), NULL, '150.00', '29877356729584735072');
GO

INSERT INTO fabrication.machines (machinename, specification)
	VALUES (N'Fidia', 'finish'),
	(N'Coburg 1', 'rough'),
	(N'Coburg 2', 'rough'),
	(N'Rambaudi', 'finish'),
	(N'65A90', 'universal')
GO

DECLARE @operator uniqueidentifier
SELECT TOP 1 @operator=pnum
FROM hr.employees
WHERE subdivisionid='4'

INSERT INTO operator.operators_monthly_schedule (oid, [date])
	VALUES (@operator, '2022-05-12')
GO

DECLARE @operator uniqueidentifier
SELECT TOP 1 @operator=pnum
FROM hr.employees
WHERE subdivisionid='4'

DECLARE @tab uniqueidentifier
SELECT @tab=mtabid
FROM operator.operators_monthly_schedule
WHERE oid=@operator

INSERT INTO operator.operator_day_time_sheet (oid, munthlytabid, [hours], [date])
VALUES (@operator, @tab, '10.5', '2022-05-01'),
		(@operator, @tab, '11', '2022-05-03'),
		(@operator, @tab, '22.5', '2022-05-04');
		--(@operator, @tab, '11', '2022-05-03'), -- Должна быть ошибка
		--(@operator, @tab, '11', '2022-05-03'), -- Должна быть ошибка
		--(@operator, @tab, '11', '2021-05-03'), -- Должна быть ошибка
		--(@operator, @tab, '11', '2022-06-03'); -- Должна быть ошибка
GO