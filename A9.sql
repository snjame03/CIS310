CREATE TRIGGER A9
	ON LGLINE
	AFTER INSERT,DELETE,UPDATE
AS
BEGIN
		DECLARE @INVNUM CHAR(4)
		DECLARE @TOTAL MONEY

IF(EXISTS (SELECT * FROM INSERTED))
BEGIN
	DECLARE INSERTED_CURSOR CURSOR FOR 
	SELECT INV_NUM, SUM(LINE_QTY*LINE_PRICE) AS TOTAL
	FROM INSERTED
	GROUP BY INV_NUM

	OPEN INSERTED_CURSOR
	FETCH NEXT FROM INSERTED_CURSOR
		INTO @INVNUM, @TOTAL
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		UPDATE LGINVOICE
		SET INV_TOTAL = INV_TOTAL - @TOTAL
		WHERE INV_NUM = @INVNUM
		FETCH NEXT FROM INSERTED_CURSOR
				INTO @INVNUM, @TOTAL
	END
	CLOSE INSERTED_CURSOR
	DEALLOCATE INSERTED_CURSOR
END

IF(EXISTS (SELECT * FROM DELETED))
BEGIN
	DECLARE DELETED_CURSOR CURSOR FOR
	SELECT INV_NUM, SUM(LINE_QTY*LINE_PRICE) AS TOTAL
	FROM DELETED
	GROUP BY INV_NUM

	OPEN DELETED_CURSOR
	FETCH NEXT FROM DELETED_CURSOR
			INTO @INVNUM, @TOTAL
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		UPDATE LGINVOICE
		SET INV_TOTAL = INV_TOTAL + @TOTAL
		WHERE INV_NUM = @INVNUM
		FETCH NEXT FROM DELETED_CURSOR
				INTO @INVNUM, @TOTAL
	END
	CLOSE DELETED_CURSOR
	DEALLOCATE DELETED_CURSOR
END
END


SELECT *
FROM LGINVOICE
SELECT *
FROM LGLINE
WHERE INV_NUM=104 AND
	LINE_NUM =1

UPDATE LGLINE
SET LINE_QTY = LINE_QTY + 3
WHERE INV_NUM = 104 AND LINE_NUM =1