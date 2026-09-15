-- ============================================================
-- BASELINE: dbo.UspSPEReprocessarPacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEReprocessarPacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSPEReprocessarPacotes]
as 
begin

	SET NOCOUNT ON;


 	truncate table tb_spe_pacotes_para_reprocessar

 	--Insere rotas que manteve diferença nos indicadores ou que não foram finalizadas
 	insert into tb_spe_pacotes_para_reprocessar (CodigoPacote, IdTransportadora, IdStation)
	


 select
     pacote.codigopacote,
     pacote.idtransportadora,
 	pacote.idstation
 from (

 select
         a.DataReferencia
 	, a.codigopacote
 	, b.nomehub
 	, a.idtransportadora
 	, b.idstation
     from tb_spe_pacotes_V5 as a

         inner join tb_spe_rotas_v5 as b
         on a.codigorota = b.codigorota
             and a.idtransportadora = b.idtransportadora

     where a.DataReferencia between cast(getdate()-4 as date) and cast(getdate() as date)
         and a.idtransportadora = 20230015
         and a.Excluido = 0
         and b.Excluido = 0
        --  and nomehub = 'XPT_BA_Mata de São João'

 ) as pacote

 where 
 	pacote.codigopacote not in (

 select CodigoPacote
 from tb_spe_sla_stuck nolock
 where 1=1 
 and StatusColeta in ('Delivered', 'Return_LMHub_Received')
 and CAST(DataHoraColeta as date)  between cast(getdate()-4 as date)  and cast(getdate() as date)
 group by CodigoPacote
 	)
    union all

 select distinct 
     pacote.codigopacote,
     pacote.idtransportadora,
 	pacote.idstation
 from (

 select
         a.DataReferencia
 	, a.codigopacote
 	, b.nomehub
 	, a.idtransportadora
 	, b.idstation
     from tb_spe_pacotes_V5 as a

         inner join tb_spe_rotas_v5 as b
         on a.codigorota = b.codigorota
             and a.idtransportadora = b.idtransportadora

     where 1=1
         and a.DataReferencia  between cast(GETDATE()-4 as date) and cast(GETDATE() as date)
         and a.idtransportadora = 20230015
         and a.Excluido = 0
         and b.Excluido = 0
         --and codigopacote  ='BR2561920647901'
   --      and nomehub = 'XPT_BA_Mata de São João'

 ) as pacote
     left join (
 	select distinct
         codigopacote
     from tb_spe_sla_stuck 
	
 ) as sla
     on pacote.codigopacote = sla.codigopacote
 where sla.codigopacote is null















 --select
 --    pacote.codigopacote,
 --    pacote.idtransportadora,
 --	pacote.idstation
 --from (

 --select
 --        a.DataReferencia
 --	, a.codigopacote
 --	, b.nomehub
 --	, a.idtransportadora
 --	, b.idstation
 --    from tb_spe_pacotes_V5 as a

 --        inner join tb_spe_rotas_v5 as b
 --        on a.codigorota = b.codigorota
 --            and a.idtransportadora = b.idtransportadora

 --    where a.DataReferencia = CAST(GETDATE()-1 as date)
 --        and a.idtransportadora = 20230015
 --        and a.Excluido = 0
 --        and b.Excluido = 0
 --       -- and nomehub = 'XPT_BA_Camaçari_02'

 --) as pacote
 --    left join (
 --	select distinct
 --        codigopacote
 --    from tb_spe_sla_stuck 
	
 --) as sla
 --    on pacote.codigopacote = sla.codigopacote
 --where sla.codigopacote is null


 --union all

--  select
--      pacote.codigopacote,
--      pacote.idtransportadora,
--  	pacote.idstation
--  from (

--  select
--          a.DataReferencia
--  	, a.codigopacote
--  	, b.nomehub
--  	, a.idtransportadora
--  	, b.idstation
--      from tb_spe_pacotes_V5 as a

--          inner join tb_spe_rotas_v5 as b
--          on a.codigorota = b.codigorota
--              and a.idtransportadora = b.idtransportadora

--      where a.DataReferencia >= CAST(GETDATE()-10 as date)
--          and a.idtransportadora = 20230015
--          and a.Excluido = 0
--          and b.Excluido = 0
--          and nomehub <> 'XPT_BA_Camaçari_02'

--  ) as pacote

--  where 
--  	pacote.codigopacote not in (

--  select CodigoPacote
--  from tb_spe_sla_stuck nolock
--  where StatusColeta in ('Delivered', 'Return_LMHub_Received')
--  and CAST(DataHoraColeta as date) >= CAST(GETDATE()-10 as date)
--  group by CodigoPacote
--  	)

end
GO
