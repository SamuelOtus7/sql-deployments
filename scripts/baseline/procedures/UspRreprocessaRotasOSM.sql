-- ============================================================
-- BASELINE: dbo.UspRreprocessaRotasOSM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspRreprocessaRotasOSM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspRreprocessaRotasOSM] as

/*
Reprocessa rotas que por algum motivo não gerou km mesmo tendo apontamento dentro da primeira e ultima entrega
Atualiza coluna FaixaPrimeiroUltimoPacote para verificar se o motorista em apontamento na faixa de horario. Indicador utilizado no relatorio de aderencia
*/
declare @date_ini date = cast(getdate()-2 as date)
declare @date_fim date = cast(getdate()-1 as date)


--reprocessar rotas que usaram app dentro da faixa de horario
update a
set
	processamento = 0

from tb_ml_processamento_km_rotas as a
inner join 
(
	select *
	from tb_ml_rotas
	where DataReferencia between @date_ini and @date_fim
	and usouapp = 'sim'
	and KmColetadoApp = 0
	and FaixaPrimeiroUltimoPacote is null
    and excluido = 0
) as b 
on a.idrota = b.idrota



update a
set
	processamento = 0

from tb_ml_processamento_km_rotas as a
inner join 
(
	select *
	from vw_rotas
	where DataReferencia between @date_ini and @date_fim
	--and idtransportadora = 2087146923
) as b 
on a.idrota = b.idrota
where pontosRotasPacotesKm = 0

/*
--atualiza quem nao tem entrega na faixa de horario
update a
set 
FaixaPrimeiroUltimoPacote = 0
--select  a.*
from tb_ml_rotas as a
left join vw_rotas_horario_entrega as b
on a.idrota = b.idrota

where DataReferencia between @date_ini and @date_fim
and a.usouapp = 'sim'
and b.idrota is null
and a.KmColetadoApp = 0
and a.excluido = 0
*/

--atualiza quando tem entrega na faixa de horario
update a
set FaixaPrimeiroUltimoPacote = 1

from tb_ml_rotas as a
inner join 
(
select IdRota from [vw_rotas_motoristas] 
where data  between @date_ini and @date_fim
and usouapp = 'sim'  
and FaixaPrimeiroUltimoPacote  = 'Não' 
and kmapp > 0
) as b 
on a.idrota = b.idrota


GO
