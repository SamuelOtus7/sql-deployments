-- ============================================================
-- BASELINE: dbo.USPssrsSPEGetMonitoramento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USPssrsSPEGetMonitoramento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[USPssrsSPEGetMonitoramento] AS 

DECLARE @TransportadoraId INT;

DECLARE TransportadoraCursor CURSOR FOR
SELECT cli_id_shopee
FROM tb_clientes
WHERE cli_in_ativo = 1
  AND cli_id_shopee > 0;

OPEN TransportadoraCursor;

FETCH NEXT FROM TransportadoraCursor INTO @TransportadoraId;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.[USPssrsSPEMonitoramento] @IdTransportadora = @TransportadoraId;

    FETCH NEXT FROM TransportadoraCursor INTO @TransportadoraId;
END;

CLOSE TransportadoraCursor;
DEALLOCATE TransportadoraCursor;
GO
