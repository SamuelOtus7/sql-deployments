-- ============================================================
-- BASELINE: dbo.UspSPEReprocessaPacotesMonitoramentoV4
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEReprocessaPacotesMonitoramentoV4]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
CREATE PROCEDURE [dbo].[UspSPEReprocessaPacotesMonitoramentoV4] as 

-- truncate table tb_spe_pacotes_para_reprocessar_monitoramento_v4

--drop table if EXISTS  #tabela_reprocessar
--select 
--     rotas.CodigoRota
--    ,pacote.CodigoPacote
--    ,dac_dh_coleta
--    ,rotas.DataReferencia
--    ,rotas.Idtransportadora
--    ,Station.IdStation
--    into #tabela_reprocessar

--from 
--    (
--        SELECT 
--            dac_ds_contexto as CodigoRota
--            ,dateadd(HOUR,-3,dac_dh_coleta) as dac_dh_coleta
--            ,cast(dateadd(HOUR,-3,dac_dh_coleta) as date) as DataReferencia
--            ,ROW_NUMBER() OVER(PARTITION by dac_ds_contexto order by dac_dh_coleta desc ) ordem
--            ,dac_cd_transportadora as Idtransportadora
--            , DATEDIFF(MINUTE,
--                            dateadd(HOUR,-3,dac_dh_coleta) 
--                            , GETDATE() ) delta

--        FROM 
--            db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
--        WHERE 
--            dac_ds_tipo_coleta = 'SPE4_PACKAGES'
--			and dac_in_processado = 1
--            and CAST(dac_dh_coleta  as date ) = CAST(getdate() as date ) 
--            -- and DATEDIFF(MINUTE,
--            --                 dateadd(HOUR,-3,dac_dh_coleta) 
--            --                 , GETDATE() )   between 15 and 45
--            -- and dac_ds_contexto = 'AT202403220YNWC'
--    ) as rotas

--inner join tb_spe_pacotes_v4 as pacote
--on rotas.codigorota = pacote.CodigoRota
--and rotas.Idtransportadora = pacote.IdTransportadora
--and dateadd(dd,1,rotas.DataReferencia) = pacote.DataReferencia
--and StatusEntrega = 'Assigned'
--and pacote.Excluido = 0

--left join tb_spe_rotas_v4 as Station
--on rotas.CodigoRota = Station.CodigoRota
--and rotas.Idtransportadora = Station.IdTransportadora
--and Station.excluido = 0
--where ordem  = 1
---- and rotas.CodigoRota = 'BR240945472290A'
---- and pacote.CodigoPacote = 'BR240945472290A'
---- and (
----      Delta between 15 and 20
---- or Delta between 60 and 70
---- or Delta between 120 and 140
---- )
--order by 3 desc


--MERGE INTO [dbo].[tb_spe_pacotes_para_reprocessar_monitoramento_v4] AS target
--USING #tabela_reprocessar AS source
--ON target.CodigoPacote = source.CodigoPacote
--and target.Idtransportadora = source.Idtransportadora

--WHEN MATCHED THEN
--    DELETE
--WHEN NOT MATCHED BY TARGET THEN
--    INSERT (CodigoPacote, IdTransportadora, IdStation)
--    VALUES (source.CodigoPacote, source.IdTransportadora, source.IdStation);



GO
