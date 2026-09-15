-- ============================================================
-- BASELINE: dbo.fn_pagametos
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_pagametos]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_pagametos](
    @IdPeriodo int null,
    @Rota varchar(50) null
) 
RETURNS TABLE
AS
RETURN

-- declare @idperiodo int = 718
-- , @rota int = null

select distinct 
    ppr_cd_pgto_espelho
    ,ppr_cd_pagamento_rota
  ,rotas.usouapp as usouapp
    ,cli_cd_codigo_cliente as TenantId
    ,ppr_cd_periodo
    ,pgp_nm_periodo
  ,mtn_cd_status as Status
  ,cast(mtn_dt_prazo_contestacao as date) as DataContestacao
  ,case when getdate() >= mtn_dt_prazo_contestacao  
        then 0 else DATEDIFF(day,getdate(), cast(mtn_dt_prazo_contestacao as date)) end as DiasContestacao
    ,ppr_data_referencia    as Data
    ,ppr_nome_motorista     as Motorista
  ,ppr_cd_motorista    as Usuario
  ,case when ppr_cd_motorista is null then 'Sem Cadastro' else 'Cadastrado' end as Filtro_Cadastro
    ,ppr_cd_rota            as Rota
  ,tiporota.lst_ds_label -- Incluído por murilo em 24/06/2026
    ,ppr_base_principal     as SVC
    ,ppr_cd_faixa_km        as Faixa_KM
  ,pre.IntervaloFaixa    as Faixa_Prefatura
    ,ppr_ds_tipo_veiculo    as Tipo_Veiculo
    ,pre.Veiculo      as Tipo_Veiculo_prefatura
  ,ppr_nm_cidade           as Cidade
    ,ppr_ds_ciclo          as Ciclo
  ,pre.CicloPM      as Ciclo_Prefatura
  ,case when pre.KmCiclo = 'AMBULANCE' then 'Sim' else 'Não' end AmbulanciaPreFatura
    ,ppr_qt_pacotes          as Pacotes
    ,ppr_qt_pacotes_entregues as PacotesEntregues
    ,ppr_qt_pontos      as Pontos
    ,ppr_qt_paradas     as QuantidadeParadas
    ,ppr_vl_base      as Base
    ,isnull(ppr_vl_paradas,0) + isnull(ppr_vl_pontos,0)  as Paradas
    ,ppr_vl_risco      as Risco
    ,ppr_vl_ajudante    as Ajudante  
    ,ppr_vl_dom_fer      as Dom_Fer
    ,case when ppr_fl_desconto = 0 then ppr_vl_lancamentos end as Lancamentos
    ,isnull(ppr_vl_bonus,0) + isnull(ppr_vl_bonus_ds,0)       as Bonus
    ,case when ppr_fl_desconto = 0 then ppr_vl_total  end     as Total

    ,ppr_dh_modificacao as DataAtualizacao
  ,ppr_total_km as KmTotal
  ,case when ppr_total_km > 100 then ppr_total_km-100 else 0 end  as KmTotalExcedente
  ,ppr_vl_desconto  Desconto
  ,ppr_lcto_observacao Observacao
  ,ppr_ds_placa Placa
    --,cast(ppr_dh_modificacao as date) as DataAtualizacaoControlePowerBI
    ,cast(case when b.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else b.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
  ,ppr_vl_pedagio Pedagio
  ,ppr_vl_recarga AS RecargaEletrica
  ,case when ppr_fl_desconto = 0 then case when isnull(ppr_vl_lancamentos,0) > 0 then ppr_vl_lancamentos end end LancamentosPositivos
  ,case when ppr_fl_desconto = 0 then case when ppr_vl_lancamentos < 0 then ppr_vl_lancamentos end end LancamentosNegativos
  ,ppr_vl_aluguel ValorAluguel
  ,case when ppr_in_ambulancia = 1 then 'Sim' else 'Não' end as FiltroAmbulancia-- INSERIDO POR MURILO 17/06/2026
  ,m.Banco
  ,m.NomeTitular
  ,m.CpfTitular
  ,m.CnpjTitular
  ,m.Agencia
  ,m.Conta
  ,m.TipoConta
  ,m.TipoChavePix
  ,m.ChavePix
  ,a.ppr_nm_cluster
  ,a.ppr_total_km_meli
  ,a.ppr_total_km_rtt
  ,m.CnpjEmpresa
  ,m.RazaoSocial
  ,m.NomeFantasia
  ,a.ppr_vl_adicional_km AdicionalKm
  ,case when ppr_fl_desconto = 1 then ppr_vl_total end ValorAdiantado
  ,case when ppr_ds_tipo_veiculo is not null or pre.Veiculo is not null then case when ppr_ds_tipo_veiculo = pre.Veiculo + case when pre.ContinuacaoVeiculo is not null then ' - ' + pre.ContinuacaoVeiculo else '' end then 'Igual' else 'Diferente' end end ValidacaoVeiculoPreFatura
    ,ppr_motivo_rota_zerada
    ,ppr_vl_success_delivery PercDS
    ,ppr_per_endereco_nao_visitado PercNotVisited
    ,ppr_motivo_rota_zerada MotivoRotaZerada
    ,isnull(ppr_vl_pacotes,0) as AdicionalPacotes

from tb_pgto_periodo_rota a with(nolock)

inner join tb_pag_espelhos as pag
on ppr_cd_motorista_nfs = mtn_cd_motorista_nfs

inner join tb_pgto_periodo as b with(nolock)
on a.ppr_cd_periodo = b.pgp_cd_periodo

left join tb_clientes as cli
on b.pgp_cd_cliente = cli.cli_cd_codigo_cliente

--Inclusão para pegar dados de pagamentos dos motoristas solicitado pela 50+
left join vw_dados_motoristas m on a.ppr_cd_motorista = m.CodigoUsuario and b.pgp_cd_cliente = m.IdCliente

left join tb_fin_prefatura as pre
on a.ppr_cd_rota = pre.IdRota

--Inclusão para trazer coluna usouapp           MURILO 12/02/2026
left join tb_ml_rotas rotas
  on TRY_CONVERT(bigint, a.ppr_cd_rota) = TRY_CONVERT(bigint, rotas.idrota)

--Incluido em 11/03/2026 por Saulo Barros para verificar qual marketplace do periodo
left join tb_lista mkt with(nolock) on b.pgp_cd_cliente_transportadora = mkt.lst_cd_lista

left join tb_lista tiporota
on ppr_cd_tipo_pgto = tiporota.lst_cd_lista -- Incluído por murilo em 24/06/2026


where 1=1 
--and pgp_cd_status = 1
and pgp_cd_periodo >= 370 
--and (@IdPeriodo is null or ppr_cd_periodo = @IdPeriodo)
--and (@Rota is null or ppr_cd_rota = @Rota)
and ppr_in_excluido = 0 
and b.pgp_in_excluido = 0
--and ppr_cd_rota is not null

--Adicionado por Saulo Barros em 11/03/2026 para não considerar períodos de pagamento administrativo
and isnull(mkt.lst_ds_valor,'') <> 'Administrativo'

 
GO
