USE [DevDB2022-py2-viklit];
GO

INSERT INTO hr.subdivision(subdivisionname, subdfunctions)
	VALUES (N'������� �������-�����������', N'������������ ��������� � 
	�����������. �������� ��������� � ������. ������� � ����������� ����������������� �����. �������������� � ���������� ������������ ���������, 
	�������� ������ � �������. �������� ��.'),
	(N'�������-�����������', N'�������������� � ���������� ������������ ���������, 
	�������� ������ � �������. �������� ��.'),
	(N'�������� 3� ������ �������', N'��������� �� �� ������. 
	������ �� 3-������������ �������, - ���������� �������� �������� ��������������� ������������'),
	(N'�������� 5� ������ �������', N'��������� �� �� ������.)
	������ �� 5-������������ �������, - ���������� �������� �������� ��������������� ������������'),
	(N'��������� ������������', N'����������� � �������� ���������������� ���������. 
	���� ������������� �� �������� ������������, ������ �����.'),
	(N'������� ��������', N'��������� ���������������� ������. ���������� ����������������� �����, 
	������������� ������� ����� ����� ���������-�������������. ��������� ����� ��������� ���������.');
GO

INSERT INTO bookkeeping.requisites (fullbankname, shortbankname, email, [k-order], BIK, INN, KPP, OGRN, SWIFT)
	VALUES (
		N'��������� ����������� �������� ����� ������-��������û',
		N'��� ����� ������-���������',
		N'info@bspb.ru',
		N'30101810900000000790 ������-�������� �� ����� ������',
		N'044030790',
		N'7831000027',
		N'780601001',
		N'1027800000140',
		N'JSBSRU2P');
GO

INSERT INTO hr.employees(reqid, subdivisionid, firstname, lastname, patronymic, birthdate, passport, snils, employmentdate, leadid, salary, bank_ac�)
	VALUES ('1', '5', N'�������', N'��', N'����������', '1978-01-11', '1036786266', '555-345-022-18', GETDATE(), NULL, '175.00', '09847356729584735074'),
	('1', '6', N'�������', N'���������', N'�������������', '1981-04-13', '1036786256', '555-345-022-98', GETDATE(), NULL, '130.00', '29847356729584735074'),
	('1', '4', N'������', N'����������', N'��������', '1993-07-14', '1035786256', '555-345-022-38', GETDATE(), NULL, '112.00', '29877356729584735074'),
	('1', '4', N'�����', N'�������', N'�������������', '1975-10-21', '1035786251', '555-345-122-12', GETDATE(), NULL, '150.00', '29877356729584735072');
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
		--(@operator, @tab, '11', '2022-05-03'), -- ������ ���� ������
		--(@operator, @tab, '11', '2022-05-03'), -- ������ ���� ������
		--(@operator, @tab, '11', '2021-05-03'), -- ������ ���� ������
		--(@operator, @tab, '11', '2022-06-03'); -- ������ ���� ������
GO