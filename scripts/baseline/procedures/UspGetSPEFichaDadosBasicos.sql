-- ============================================================
-- BASELINE: dbo.UspGetSPEFichaDadosBasicos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetSPEFichaDadosBasicos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGetSPEFichaDadosBasicos]
(
	@Transportadora int,
	@Rota varchar(50)
)
as

select 
     a.IdTransportadora
    ,a.DataReferencia
    ,a.CodigoRota
    ,a.NomeHub
    ,a.Hub
    ,a.Motorista
	,case when a.RotaFinalizada = 1 then 'Finalizada' else 'Aberta' end [Status]    
    ,'Last Mile' TipoRota
    ,a.CidadeReferencia
    ,c.DataPrimeiraEntrega
    ,PacotesEntregues / cast(TotalPacotes as decimal(10,2)) as Percentualprogresso

    ,TotalPacotes
    ,PacotesEntregues
    ,PacotesNaoEntregue
    ,PacotesPendentes
    ,0 transferidos 
    ,GETDATE() DataAtualizacao
    ,0 as pnr
    ,null as Ambulancia
    ,Paradas as QuantidadeParadas
    
    -- ,b.bss_ds_cidade as PercentualEntregasBemSucedidas

from vw_rotas_spe_v4  as a


inner join (
    select
    datareferencia
    ,IdTransportadora
    ,codigorota
    ,min(DataHoraEntrega) as DataPrimeiraEntrega 
 from tb_spe_pacotes_v4 
--  where codigorota = 'AT20240326104PM'
 group by datareferencia, IdTransportadora,codigorota
) as c
on a.DataReferencia = c.DataReferencia
and a.CodigoRota = c.CodigoRota


where a.IdTransportadora = @Transportadora
and a.codigorota = @Rota
GO
