-- ============================================================
-- BASELINE: dbo.Usp_AlarmeRotasSemPacote
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeRotasSemPacote]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_AlarmeRotasSemPacote] as 

Declare @dataref date = cast(getdate()-10 as date)
	DROP TABLE IF EXISTS #base;
    
select
    c.cli_ds_nome 
    ,rotas.DataReferencia	
    ,count(*) qtd
	INTO #base
FROM   
tb_ml_rotas rotas  with(nolock)

left join tb_ml_pacotes hist 
on rotas.IdRota = hist.IdRota  
and rotas.IdTransportadora = hist.IdTransportadora   

join tb_clientes c with(nolock)              
on rotas.idtransportadora = c.cli_id_logistics   
and cli_in_ativo=1 
and cli_in_excluido = 0  

WHERE   
rotas.excluido = 0  
AND rotas.StatusRota <> 'planned'  
AND rotas.datareferencia >= CAST(DATEADD(DAY, -10, GETDATE()) AS DATE)  
and rotas.datareferencia < cast(getdate() as date)  
and hist.IdRota is null	

group by c.cli_ds_nome ,rotas.DataReferencia



IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dataReferencia, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), qtd ) + CHAR(10)
    FROM #base;


    RAISERROR ('Estamso coletando rotas mas nao estamos coletando pacotes para as transportados abaixo. Verificar com time de desenvimento se todas as instancias de referente a coletas de pacote estao funcionando: %s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;

GO
