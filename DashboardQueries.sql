--Set 07:30 and Date
SELECT SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 07, 30);

--Test Query
SELECT *
	FROM Q_INCIDENTS
		WHERE Addeddate >= (SELECT SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 07, 30))
		AND Addeddate <= SYSDATETIME ()
		ORDER BY Addeddate DESC;

--Number of Calls Logged (Total)
SELECT Count (SERVICEREQID), Priority
	FROM Q_INCIDENTS
		WHERE Addeddate >= (SELECT SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 07, 30))
		AND Addeddate <= SYSDATETIME ()
		GROUP BY Priority

--Calls logged by team for the day in question
SELECT SERVICEREQID, GROUPTEXT, Priority, State
	FROM Q_INCIDENTS
		WHERE Addeddate >= (SELECT SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 07, 30))
		AND Addeddate <= SYSDATETIME ()
		ORDER BY Addeddate DESC

--Calls for a team, showing open/on hold calls by priority
SELECT SERVICEREQID, GROUPTEXT, Priority, Status
	FROM sunrise.INCIDENTS
		WHERE Addeddate >= (SELECT SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 07, 30))
		AND Addeddate <= SYSDATETIME ()
		AND STATEID = 105001127
		OR STATEID = 105001128
		ORDER BY Addeddate DESC

--Call States 105001127 = open, 105001129 = closed, 105001128 = on hold

--Calls logged for each team that are still open
SELECT SERVICEREQID, GROUPTEXT, Priority, State
	FROM Q_INCIDENTS
		WHERE State = 'Open'
		AND GROUPTEXT NOT IN ('Agresso Operation Group', 'Change Control & DR Team', 'Everyone in User Profile', 'Improvement & Projects Team', 'Projects', 'Relocation Team', 'Schools Admin Team', 'Third Party')
			ORDER BY SERVICEREQID

--Calls that are 30 days or more old
SELECT *
	FROM Q_INCIDENTS
	WHERE ADDEDDATE < DATEADD(Day,-30,GETDATE())

--Calls that are 30 days or more old for calls either open or on hold.
SELECT *
	FROM Sunrise.INCIDENTS
	WHERE ADDEDDATE < DATEADD(Day,-30,GETDATE())
		AND StateID in ('105001127', '105001128')
			ORDER BY ADDEDDATE DESC

SELECT SERVICEREQID, GROUPTEXT, AddedDate, Priority, Status
	FROM Sunrise.INCIDENTS
	WHERE ADDEDDATE < DATEADD(Day,-30,GETDATE())
		AND StateID in ('105001127', '105001128')
			ORDER BY ADDEDDATE DESC
			
--Calls that have not been updated for 5 days
SELECT SERVICEREQID, GROUPTEXT, AddedDate, Priority, Status, UPDATEDDATE
	FROM Sunrise.INCIDENTS
	WHERE ADDEDDATE < DATEADD(Day,-5,GETDATE()) and UPDATEDDATE =  GETDATE ()
		AND StateID in ('105001127', '105001128')
			ORDER BY ADDEDDATE DESC
			
--Calls logged and closed by the service desk within the same working day that have not been assigned to another team
SELECT  SERVICEREQID, GROUPTEXT, AddedDate, Priority, Status, UPDATEDDATE, ADDEDBY
	FROM [sunrise].[INCIDENTS]
			WHERE Sunrise.INCIDENTS.GROUPTEXT =  ' '
				AND Sunrise.INCIDENTS.Addeddate >= (SELECT SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 00, 01))
					AND Sunrise.INCIDENTS.CLOSEDDT <= (SELECT SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 23, 59))
						AND Sunrise.INCIDENTS.STATEID = 105001129
							ORDER BY Sunrise.INCIDENTS.ADDEDDATE DESC;
							
--Calls logged by department
SELECT SERVICEREQID, NAME, DepartmentName, DepartmentID, Addeddate
	FROM Q_INCIDENTS
		ORDER BY Addeddate DESC;

--Desktop Calls Closed Report
SELECT GROUPTEXT,[OWNERTEXT] as 'Team Member', COUNT([OWNERTEXT]) as 'Jobs Closed'
FROM [SostenutoLive].[sunrise].[INCIDENTS]
WHERE STATEID = 105001129 AND (GROUPTEXT = 'Desktop Team' OR GROUPTEXT = 'Desktop Visit Team') AND ADDEDDATE > GETDATE()-28 -- 105001129 is closed, date added less than 28 days ago.
GROUP BY GROUPTEXT,OWNERTEXT
ORDER BY GROUPTEXT

--Desktop Calls Closed Report
SELECT GROUPTEXT,[UpdatedBy] as 'Team Member', COUNT([OWNERTEXT]) as 'Jobs Closed'
FROM [SostenutoLive].[sunrise].[INCIDENTS]
WHERE STATEID = 105001129 AND (GROUPTEXT = 'Desktop Team' OR GROUPTEXT = 'Desktop Visit Team') AND ADDEDDATE > GETDATE()-28 -- 105001129 is closed, date added less than 28 days ago.
GROUP BY GROUPTEXT,OWNERTEXT
ORDER BY GROUPTEXT

--System Calls Closed Report
SELECT GROUPTEXT,[OWNERTEXT] as 'Team Member', COUNT([OWNERTEXT]) as 'Jobs Closed'
FROM [SostenutoLive].[sunrise].[INCIDENTS]
WHERE STATEID = 105001129 AND (GROUPTEXT = 'CareSupport Team' OR GROUPTEXT = 'Agresso Team' or GROUPTEXT = 'Systems Team') AND ADDEDDATE > GETDATE()-28 -- 105001129 is closed, date added less than 28 days ago
GROUP BY GROUPTEXT,OWNERTEXT
ORDER BY GROUPTEXT

--AVG Overall Health CHECK
SELECT DISTINCT ag.name AS 'AVG Name', db.name AS 'Database Name',avg.primary_replica AS 'Current Primary Replica' ,  ags.synchronization_state_desc AS 'AVG Sync State',  avg.primary_recovery_health_desc AS 'AVG Primary Replica Health', avg.synchronization_health_desc AS 'Overall AVG Health',  ags.database_state_desc AS 'Database State'
	FROM sys.dm_hadr_database_replica_states ags
		INNER JOIN sys.availability_groups ag ON ag.group_id = ags.group_id
			INNER JOIN [msdb].[sys].[databases] db ON ags.database_id = db.database_id
				INNER JOIN sys.dm_hadr_availability_group_states avg ON ag.group_id = avg.group_id
				WHERE database_state_desc IS NOT NULL
				
--Data Driven AVG Check 01
SELECT DISTINCT ag.name AS 'AVG Name', db.name AS 'Database Name',avg.primary_replica AS 'Current Primary Replica' ,  ags.synchronization_state_desc AS 'AVG Sync State',  avg.primary_recovery_health_desc AS 'AVG Primary Replica Health', avg.synchronization_health_desc AS 'Overall AVG Health',  ags.database_state_desc AS 'Database State'
	FROM sys.dm_hadr_database_replica_states ags
		INNER JOIN sys.availability_groups ag ON ag.group_id = ags.group_id
			INNER JOIN [msdb].[sys].[databases] db ON ags.database_id = db.database_id
				INNER JOIN sys.dm_hadr_availability_group_states avg ON ag.group_id = avg.group_id
					WHERE database_state_desc IS NOT NULL AND avg.synchronization_health_desc = 'NOT_HEALTHY'
						ORDER BY ag.name, db.name;
						
--Data Driven AVG Check Report 
SELECT *
	FROM [BIReportingDB].[dbo].[AVGHealthCheckReport]
		WHERE AVGHealthState = 'UN_HEALTHY'
			ORDER BY AVGName, DatabaseName;
				
--Change Management Implementation Report
SELECT ch.SERVICEREQID AS 'Change ID', ch.DESCRIPTION AS 'Change Description', tn.COSMETICVALUE AS 'Primary Implementation Team', ch.STRTDT1 AS 'Implementation start date and time', ch.ENDDTE1 AS 'Implementation end date and time'
	FROM [sunrise].[CHANGE] ch
		INNER JOIN [sunrise].[S_FLD_DEFAULTDATA] tn ON ch.IMPGRP1 = tn.ACTUALVALUE
			WHERE STATEID = 105001154 AND FIELDID = '106011309' AND STRTDT1 != '1753-01-01 00:00:00.000' --Conditioned on pending implementation, teams implementing and where the start date is not the system default.
				ORDER BY STRTDT1 DESC;

