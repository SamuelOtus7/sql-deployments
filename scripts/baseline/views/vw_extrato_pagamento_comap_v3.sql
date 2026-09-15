-- ============================================================
-- BASELINE: dbo.vw_extrato_pagamento_comap_v3
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_extrato_pagamento_comap_v3]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_extrato_pagamento_comap_v3] as



select 
    ppr_cd_pgto_espelho,
    mtn_cd_pgto_periodo ,
    placa,
    Base,
    Motorista,
    Responsavel,
    TotalReceber,
    TotalDiariaLiqPre,
    ValorAvulso,
    Parada,
	Pedagio,
    --isnull([Pedágio],0)             as Pedagio, ALTERAÇÃO FEITA POR MURILO 08/01/2025 COLUNA NÃO ESTAVA TRAZENDO OS VALORES DE PEDAGIO
    risco,
    ppr_vl_ajudante,
    ppr_vl_dom_fer,

    isnull([PF - Pacote Perdido],0)       as PacotePerdido,
    isnull([PF - Endereço não visitado],0) as EnderecaoNaoVisitado,
    isnull([PF - PNR],0)                  as PNR,
    isnull([Ambulância],0)                as Ambulancia,
    isnull([Backup],0)                    as [Backup],
    isnull([Abastecimento],0)             as Abastecimento,
    isnull([Incentivo],0)                 as [Incentivo],
    
    QtdRotas

from (
    select  
        t.plm_nm_tipo,
        ppr_cd_pgto_espelho,
        ppr_ds_placa as placa,
        mtn_cd_pgto_periodo,
        mtn_base_principal as Base,
        mtn_nome_motorista as Motorista,
        cadResp.usr_nm_usuario as Responsavel,
        sum(ppr_vl_total) as TotalReceber,
        sum(case when ppr_cd_rota is not null then ppr_vl_base else 0 end) as TotalDiariaLiqPre,
        sum(case when ppr_lcto_cd_lancamento is null and ppr_cd_rota is null then ppr_vl_base else 0 end) as ValorAvulso,
        sum(ppr_vl_lancamentos) as ppr_vl_lancamentos,
        sum(ppr_vl_paradas) as Parada,
        sum(ppr_vl_pedagio) as Pedagio,
        sum(ppr_vl_risco) as risco,
        sum(ppr_vl_ajudante) as ppr_vl_ajudante,
        sum(ppr_vl_dom_fer) as ppr_vl_dom_fer,
        --sum(ppr_qtd_rota) as QtdRotas,
		count(*) QtdRotas,

        -- aqui está a coluna que será usada no PIVOT
        sum(
            case 
                when isnull(lanc.tlm_cd_tipo,lancr.tlm_cd_tipo) = 489 
                    then isnull(ppr_vl_base,0) * -1 
                else coalesce(lanc.tlm_vl_valor_descontos,lancr.tlm_vl_valor_descontos,0) 
            end
        ) + sum(coalesce(lanc.tlm_vl_valor_adicional,lancr.tlm_vl_valor_adicional,0)) as valor
    
    from tb_pgto_periodo_rota as a
          inner join tb_pgto_periodo as pgto
            on a.ppr_cd_periodo = pgto.pgp_cd_periodo


        inner join tb_pag_espelhos as pag
            on ppr_cd_pgto_espelho = pag.mtn_cd_motorista_nfs
        left join tb_pgto_rotas_lanc_manuais as cod
            on a.ppr_lcto_cd_lancamento = plm_cd_lancamentos
        left join tb_lancamentos_manuais as lanc
            on lanc.tlm_cd_lancamento_manual = cod.plm_cd_lancamento
        left join (
            select  
                 cast(tlm_dh_referencia as date)  as tlm_dh_referencia,
                tlm_cd_rota,
                tlm_cd_tipo,
                sum(tlm_vl_valor_adicional) as tlm_vl_valor_adicional,
                sum(tlm_vl_valor_descontos) * -1 as tlm_vl_valor_descontos
            from vw_lancamentos_manuais_aprovados
            group by tlm_cd_rota, tlm_cd_tipo,  cast(tlm_dh_referencia as date)
        ) as lancr
            on lancr.tlm_cd_rota = ppr_cd_rota
             and lancr.tlm_dh_referencia between pgp_dt_inicio and pgp_dt_fim


        left join tb_tipos_lancamentos_manuais as t 
            on isnull(lanc.tlm_cd_tipo,lancr.tlm_cd_tipo) = t.plm_cd_tipo_lancamento_manual
 	
        left join tb_usuario as cad
	        on pag.mtn_cd_motorista  = cad.usr_cd_usuario

        left join tb_usuario as cadResp
	        on cad.usr_cd_usr_responsavel_contrato = cadResp.usr_cd_usuario

    where 1=1
        and ppr_in_excluido = 0
		--and ppr_cd_rota = '314776183'
        --and ppr_cd_periodo = 2086

      --and ppr_cd_motorista_nfs = 880736
      --and ppr_cd_rota  <> '302875497'

      --and t.plm_nm_tipo in ('PF - Pacote Perdido','PF - Endereço não visitado','PF - PNR','Ambulância','Backup','Abastecimento')
    group by 
        t.plm_nm_tipo,
        ppr_cd_pgto_espelho,
        ppr_ds_placa,
        mtn_cd_pgto_periodo,
        mtn_base_principal,
        mtn_nome_motorista,
        cadResp.usr_nm_usuario
) as src
pivot (
    sum(valor) 
    for plm_nm_tipo in ([PF - Pacote Perdido],[PF - Endereço não visitado],[PF - PNR],[Ambulância],[Backup],[Abastecimento],[Pedágio],[Incentivo])
) as p;
GO
