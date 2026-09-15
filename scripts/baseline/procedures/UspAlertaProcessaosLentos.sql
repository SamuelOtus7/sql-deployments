-- ============================================================
-- BASELINE: dbo.UspAlertaProcessaosLentos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAlertaProcessaosLentos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[UspAlertaProcessaosLentos] as

--  EXEC dbo.UspMonitoraConsultasLentas2 60;

declare @Qtde  int 

drop table if exists  #base 
SELECT SessionId,  count(*) qtd
into #base
FROM dbo.LogConsultasLentas nolock
where 1=1
and Banco not in ('DW_ZemaSeguros','MDODW')
and HostName not in ('IMEDIATO-BANCOS')
and DataRegistro >= DATEADD(MINUTE,-1,getdate())
and SpidBloqueadoPor is not NULL
group by  SessionId




set @Qtde  = (
                SELECT count(*)
                FROM #base nolock
            
        )



IF @Qtde > 0
    BEGIN
        RAISERROR (
            N'?? Consultas com mais de 1 minuto de execucao, consulte a tabela LogConsultasLentas.',
            16, 1
        );
    END
 
GO
