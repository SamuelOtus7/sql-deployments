-- ============================================================
-- BASELINE: dbo.vw_erros_coleta_detalhes_comprador
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_erros_coleta_detalhes_comprador]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_erros_coleta_detalhes_comprador] as 

select  distinct 
ins.idtransportadora
, b.coderro	
,ins.idpacote
,b.dec_ds_erro

 from (
            select  idtransportadora,idrota,idpacote 
            from vw_ml_hist_insucesso
            where DataReferencia = cast(getdate()as date) 
            and idtransportadora in (1726310024,678279205,2130011770,1950609251
            ,472463006,652375997,652375997,643493085)
            and NomeComprador is null
 ) as ins
 left join 
 (
    select
     right(dec_ds_erro,3) coderro
    ,SUBSTRING(
            dec_ds_contexto,
            CHARINDEX('package-detail/', dec_ds_contexto) + LEN('package-detail/'),
            LEN(dec_ds_contexto)
               ) as idpacote 
    ,*
    from tb_Dra_erros_coleta as a
    where dec_ds_tipo_coleta = 'ML_PACKAGE_DETAIL'
    and cast(dec_dt_referencia as date)  =  cast(getdate()as date) 
) as b
on b.idpacote = ins.idpacote
GO
