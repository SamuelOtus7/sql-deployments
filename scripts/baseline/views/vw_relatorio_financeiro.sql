-- ============================================================
-- BASELINE: dbo.vw_relatorio_financeiro
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_relatorio_financeiro]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_relatorio_financeiro] as

select
     ppr_cd_pagamento_rota
    ,cli_cd_codigo_cliente as TenantId
    ,ppr_cd_periodo
    ,pgp_nm_periodo
    ,ppr_data_referencia    as Data
    ,ppr_nome_motorista     as Motorista
    ,ppr_cd_rota            as Rota
    ,ppr_base_principal     as SVC
    ,ppr_cd_faixa_km        as Faixa_KM
    ,ppr_ds_tipo_veiculo    as Tipo_Veiculo
	,ppr_nm_cidade 	        as Cidade
    ,ppr_ds_ciclo	        as Ciclo
    ,pre.CicloPM          as CicloPMFatura
    ,ppr_qt_pacotes	        as Pacotes
    ,ppr_qt_pacotes_entregues as PacotesEntregues
    ,ppr_qt_pontos	    as Pontos
    ,ppr_qt_paradas     as QuantidadeParadas
    ,ppr_vl_base	    as Base
    ,ppr_vl_paradas	    as Paradas
    ,ppr_vl_risco	    as Risco
    ,ppr_vl_ajudante    as Ajudante	
    ,ppr_vl_dom_fer	    as Dom_Fer
    ,ppr_vl_lancamentos as Lancamentos
    ,ppr_vl_bonus       as Bonus
    ,ppr_vl_total       as Total
    ,c.RecebMeli        as RecebMeli
    ,c.RecebimentoParadas as RecebimentoParadas
    ,c.RecebimentoRisco as RecebimentoRisco
    ,c.RecebimentoDomingo as RecebimentoDomingo
    ,c.RecebMeli - ppr_vl_total as DeltaRecebPagto
    
    ,case when ppr_vl_base = 0 or ppr_vl_base is null then 1 else 0 end as Base_Zerado
    ,case when ppr_vl_base > 0 then 1 else 0 end as Base_Com_Valor
    ,case when ppr_vl_paradas = 0 or ppr_vl_paradas is null then 1 else 0 end as Parada_Zerado
    ,case when ppr_vl_paradas > 0 then 1 else 0 end as Parada_Com_Valor
    ,case when ppr_cd_rota is not null then 1 else 0 end  as TotalRotas
    
    --crie um case when para validar os case acima e me indique o status de retorno
    ,case when ppr_vl_base = 0 or ppr_vl_base is null then 'Base Zerado'
    when ppr_vl_base > 0 then 'Base Com Valor'
    when ppr_vl_paradas = 0 or ppr_vl_paradas is null then 'Parada Zerado'
    when ppr_vl_paradas > 0 then 'Parada Com Valor'
    when ppr_cd_rota is not null then 'Total Rotas'
    when ppr_vl_base > 0 and ppr_vl_paradas > 0 and ppr_cd_rota is not null then 'Tudo Certo'
    else 'Validar' end as StatusPagamento

    ,case when RecebMeli = 0 then 1 else 0 end as RecebMeli_Zerado
    ,case when RecebMeli > 0 then 1 else 0 end as RecebMeli_Com_Valor
    ,case when RecebimentoParadas = 0 then 1 else 0 end as RecebimentoParadas_Zerado
    ,case when RecebimentoParadas > 0 then 1 else 0 end as RecebimentoParadas_Com_Valor
    ,case when RecebimentoRisco = 0 then 1 else 0 end as RecebimentoRisco_Zerado
    ,case when RecebimentoRisco > 0 then 1 else 0 end as RecebimentoRisco_Com_Valor 
    ,case when RecebimentoDomingo = 0 then 1 else 0 end as RecebimentoDomingo_Zerado
    ,case when RecebimentoDomingo > 0 then 1 else 0 end as RecebimentoDomingo_Com_Valor
    ,case when RecebMeli > 0 and RecebimentoParadas > 0 and RecebimentoRisco > 0 and RecebimentoDomingo > 0 then 1 else 0 end as RecebimentoTotal
    ,case when RecebMeli > 0 and RecebimentoParadas > 0 and RecebimentoRisco > 0 and RecebimentoDomingo > 0 then 'Tudo Certo' else 'Validar' end as StatusRecebimento
    ,pre.total as RecebimentoPrefatura
    ,1 AusenteIrisys
        
from tb_pgto_periodo_rota as a

inner join tb_pgto_periodo as b
on a.ppr_cd_periodo = b.pgp_cd_periodo

left join tb_clientes as cli
on b.pgp_cd_cliente = cli.cli_cd_codigo_cliente

left join vw_resultado_financeiro as c
on a.ppr_cd_rota = c.IdRota

left join tb_fin_prefatura as pre
on a.ppr_cd_rota = pre.IdRota

where pgp_cd_status = 1
and pgp_cd_periodo >= 100 
-- and ppr_cd_periodo = 174

union all

select  
 null ppr_cd_pagamento_rota
,periodo.idtransportadora
,pgp_cd_periodo
,pgp_nm_periodo
,pre.DataInicio
,pre.Motorista
,pre.IdRota
,pre.ServiceCenter
,pre.IntervaloFaixa
,pre.veiculo
,null cidade
,null ciclo
,pre.CicloPM as CicloPMFatura
,null Pacotes
,null PacotesEntregues
,null Pontos
,null QuantidadeParadas
,null Base
,null Paradas
,null Risco
,null Ajudante
,null Dom_Fer
,null Lancamentos
,null Bonus
,null Total
,null RecebMeli
,null RecebimentoParadas
,null RecebimentoRisco
,null RecebimentoDomingo
,null DeltaRecebPagto
,null Base_Zerado
,null Base_Com_Valor
,null Parada_Zerado
,null Parada_Com_Valor
,null TotalRotas
,null StatusPagamento
,null RecebMeli_Zerado
,null RecebMeli_Com_Valor
,null RecebimentoParadas_Zerado
,null RecebimentoParadas_Com_Valor
,null RecebimentoRisco_Zerado
,null RecebimentoRisco_Com_Valor
,null RecebimentoDomingo_Zerado
,null RecebimentoDomingo_Com_Valor
,null RecebimentoTotal
,null StatusRecebimento
,pre.Total RecebimentoPrefatura
,1 AusenteIrisys

from (
    SELECT
        a.*
        ,cli_cd_codigo_cliente idtransportadoraFiltro
    from tb_fin_prefatura  as a
    inner join tb_clientes  as b
    on a.idtransportadora = b.cli_id_logistics
) as pre
inner JOIN
(
    select 
        pgp_cd_periodo
        ,pgp_nm_periodo
        ,pgp_dt_inicio
        ,pgp_dt_fim
        ,pgp_cd_cliente as idtransportadora
        
    from tb_pgto_periodo as a
    inner join tb_clientes as b on a.pgp_cd_cliente = b.cli_cd_codigo_cliente
    where pgp_cd_periodo > 100
   -- and  pgp_cd_periodo = 161
    and pgp_cd_status = 1
) as periodo 
on pre.idtransportadoraFiltro = periodo.idtransportadora

left join tb_pgto_periodo_rota as pgto 
on pgto.ppr_cd_rota = pre.idrota
and periodo.pgp_cd_periodo = pgto.ppr_cd_periodo

where  pre.datainicio between periodo.pgp_dt_inicio and periodo.pgp_dt_fim
and pgto.ppr_cd_rota is null

GO
