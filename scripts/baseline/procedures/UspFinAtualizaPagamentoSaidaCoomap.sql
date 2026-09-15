-- ============================================================
-- BASELINE: dbo.UspFinAtualizaPagamentoSaidaCoomap
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaPagamentoSaidaCoomap]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinAtualizaPagamentoSaidaCoomap] 
(
 @CodPeriodoPagamento int 
) as 

begin

    declare
    @IdTransportadora int,
     --@CodPeriodoPagamento int = 2086,
     @idrota varchar(50) = null,
    @cd_usr int = 7, --  se receber valor null precisa
    @data_inicial date,
    @data_final date,
    @clienteid int,
    @usuarioIrisys int,
    @Motorista varchar(250),
    @IdCliTransportadora int,
    @tipocontrato int = null,
    @fontedados varchar(50),
    @agora datetime =  getdate()


    ----- parametros de filtros
    set @data_inicial = (
    select pgp_dt_inicio
    from [dbo].[tb_pgto_periodo] with (nolock)
    where pgp_cd_periodo = @CodPeriodoPagamento
)

    set @data_final = (
    select pgp_dt_fim
    from [dbo].[tb_pgto_periodo] with (nolock)
    where pgp_cd_periodo = @CodPeriodoPagamento
)

   set @clienteid = (
    select pgp_cd_cliente
    from [tb_pgto_periodo] as a (nolock)
        left join tb_clientes as b (nolock)
        on a.pgp_cd_cliente = cli_cd_codigo_cliente
    where pgp_cd_periodo = @CodPeriodoPagamento
)



drop table if exists #origemsaida
select 

     case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) <> 'B' then r.OrigemSaida else r.ServiceCenter end ServiceCenter
    ,pre.CicloPM
    ,pre.Motorista 
    ,pre.Veiculo
    ,pre.IntervaloFaixa
    ,pre.IdRota
    ,pre.FimIntervalo
    ,total - (
        (total * ISS ) + (total * Comercial) + (total * RDM) + (total * Gestao)
      )  as ppr_vl_base
    ,total * ISS        as ppr_vl_iss
    ,total * Comercial  as ppr_vl_Comercial
    ,total * RDM        as ppr_vl_RDM
    ,total * Gestao     as ppr_vl_Gestao
    ,VLParada - (
        (VLParada * ISS ) + (VLParada * Comercial) + (VLParada * RDM) + (VLParada * Gestao)
      ) ppr_vl_parada
    ,VLParada * ISS         as ppr_vl_parada_iss
    ,VLParada * Comercial   as ppr_vl_parada_Comercial
    ,VLParada * RDM         as ppr_vl_parada_RDM
    ,VLParada * Gestao      as ppr_vl_parada_Gestao
    

    ,pedagios.atp_dc_valor  as ppr_vl_pedagio
    into #origemsaida

from tb_fin_prefatura as pre

inner join tb_clientes as cli
on pre.idtransportadora =  cli.cli_id_logistics

inner join tb_ml_rotas as r
on pre.idrota  = r.idrota


left join (

         SELECT
            cdi_cd_cliente,
            bss_ds_sigla,
            bss_cd_idtransportadora,
            cdi_cd_dom_fer,
            sum(ISNULL([ISS],       0)) AS ISS,
            sum(ISNULL([Comercial], 0)) AS Comercial,
            sum(ISNULL([RDM],       0)) AS RDM,
            sum(ISNULL([Gestao],    0)) AS Gestao

        FROM [dbo].[tb_fin_cadastro_impostos] as a
        left join tb_bases as b
        on cdi_cd_base = bss_cd_base
        PIVOT (
            SUM(cdi_vl_imposto)             -- ou MAX, se não houver duplicidade por chave
            FOR cdi_ds_imposto IN ([ISS],[Comercial],[RDM],[Gestao])
        ) p
        group BY cdi_cd_cliente, bss_ds_sigla,bss_cd_idtransportadora,cdi_cd_dom_fer

) imp
on bss_ds_sigla = case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) <> 'B'  then r.OrigemSaida else r.ServiceCenter end
and bss_cd_idtransportadora = pre.IdTransportadora
and case when Dia = 'Domingo' then 1 else 0 end = cdi_cd_dom_fer

left join (
                SELECT
                     atp_ds_rota
					,atp_cd_codigo_cliente
                    ,sum(atp_dc_valor) as atp_dc_valor
                FROM [tb_atm_pedagios] (NOLOCK)
                where
					atp_in_excluido = 0
					and atp_cd_codigo_status = 1
				group by atp_ds_rota,atp_cd_codigo_cliente

		    ) pedagios
on cast(pre.idrota as varchar(50)) = pedagios.atp_ds_rota


where cli.cli_cd_codigo_cliente  = @clienteid
and r.datareferencia between @data_inicial and @data_final
and r.Excluido = 0 
and r.StatusRota <> 'planned'
--and pre.IdRota = 301074628
order by 1 , 2


update pgto 
set  
 pgto.ppr_vl_base               = base.ppr_vl_base
,pgto.ppr_vl_paradas            = base.ppr_vl_parada
,ppr_cd_faixa_km                = base.IntervaloFaixa
,ppr_total_km                   = base.FimIntervalo
,pgto.ppr_vl_parada_iss         = base.ppr_vl_parada_iss
,pgto.ppr_vl_parada_Comercial   = base.ppr_vl_parada_Comercial
,pgto.ppr_vl_parada_RDM         = base.ppr_vl_parada_RDM
,pgto.ppr_vl_parada_Gestao      = base.ppr_vl_parada_Gestao
,pgto.ppr_vl_iss                = base.ppr_vl_iss
,pgto.ppr_vl_Comercial          = base.ppr_vl_Comercial
,pgto.ppr_vl_RDM                = base.ppr_vl_RDM
,pgto.ppr_vl_Gestao             = base.ppr_vl_Gestao
,pgto.ppr_vl_pedagio            = base.ppr_vl_pedagio



from tb_pgto_periodo_rota pgto

join tb_pag_espelhos esp with(nolock) 
    on pgto.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
    and esp.mtn_cd_status IN (34,228,38)

join #origemsaida base on pgto.ppr_cd_rota = base.idrota

where
    pgto.ppr_cd_periodo = @CodPeriodoPagamento
    and pgto.ppr_cd_rota is not null
    and pgto.ppr_in_excluido = 0
			
end


GO
