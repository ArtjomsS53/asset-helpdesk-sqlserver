USE AssetHelpdesk;

-- 1) Найдём последний тикет по ASSET-0001
DECLARE @TicketId INT;

SELECT TOP (1) @TicketId = t.TicketId
FROM dbo.Tickets t
JOIN dbo.Devices d ON d.DeviceId = t.DeviceId
WHERE d.AssetTag = N'ASSET-0001'
ORDER BY t.CreatedAt DESC;

-- 2) Переводим в работу
IF @TicketId IS NOT NULL
BEGIN
    UPDATE dbo.Tickets
    SET Status = N'InProgress'
    WHERE TicketId = @TicketId AND Status = N'Open';
END;

-- 3) Добавим комментарий
IF @TicketId IS NOT NULL
BEGIN
    INSERT INTO dbo.TicketComments (TicketId, AuthorUserId, Body)
    SELECT @TicketId, u.UserId, N'Started troubleshooting. Checked adapter and network settings.'
    FROM dbo.Users u
    WHERE u.Email = N'artjoms@example.com';
END;

-- 4) Закрываем тикет
IF @TicketId IS NOT NULL
BEGIN
    UPDATE dbo.Tickets
    SET Status = N'Closed',
        ClosedAt = SYSUTCDATETIME()
    WHERE TicketId = @TicketId;
END;

-- 5) Проверка результата (тикет + комментарии)
SELECT t.TicketId, t.Title, t.Status, t.CreatedAt, t.ClosedAt
FROM dbo.Tickets t
WHERE t.TicketId = @TicketId;

SELECT tc.CreatedAt, u.FullName, tc.Body
FROM dbo.TicketComments tc
JOIN dbo.Users u ON u.UserId = tc.AuthorUserId
WHERE tc.TicketId = @TicketId
ORDER BY tc.CreatedAt;
