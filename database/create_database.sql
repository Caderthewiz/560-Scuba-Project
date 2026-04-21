--- Check that all data is being dropped

-- Possible error saying ScubaDB is in use?
IF DB_ID('ScubaDB') IS NOT NULL
BEGIN
    DROP DATABASE ScubaDB;
END
GO

CREATE DATABASE ScubaDB;
GO

USE ScubaDB;
GO