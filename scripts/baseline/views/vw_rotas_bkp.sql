-- ============================================================
-- BASELINE: dbo.vw_rotas_bkp
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_bkp]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







create view [dbo].[vw_rotas_bkp]
as

select 
distinct 
	r.IdTransportadora,
	r.Id,
	r.IdRota,
	r.DataReferencia ,
	r.DataHoraInicio,
	isnull(t2.tds_ds_traducao,r.StatusRota) as StatusRota,
	t4.tds_ds_traducao SubStatusRota,
	t3.tds_ds_traducao StatusPrazo,
	isnull(svc.svc_cd_service_center,r.ServiceCenter) ServiceCenter,
	svc.svc_nm_service_center NomeServiceCenter,
	coalesce(b.dab_nm_base,svc.svc_cd_service_center,r.ServiceCenter) Base,
	isnull(b.dab_nm_cidade,svc.svc_nm_cidade) CidadeBase,
			

	r.TipoOrigemSaida,
	r.OrigemSaida,
	r.TipoRota,
	r.TipoVeiculo,
	r.NomeMotorista,
	mot_cd_motorista as IdMotorista,
	mot_cd_usuario as Codigo_usuario_motorista,
	r.Placa,
	t1.tds_ds_traducao NivelExperienciaMotorista,
	r.IdNivelMotorista,
	r.NivelMotorista,
	r.QuantidadePacotesTransportados,
	r.PercentualEntregasBemSucedidas,
	r.PercentualEntregasSemRelamacaoes,
	r.PossuiAjudante,
	case when r.PossuiAjudante = 1 then 'Sim' else 'Não' end Ajudante,
    isnull(case when KmColetadoApp = 0 then KmMapaPacote else KmColetadoApp end,0)  AS KmColetado,
    r.LinkAppInterno AS LinkMapa,
	r.UsouAPP,
	r.UsuarioDA,
	CASE WHEN isnull(svc.svc_cd_service_center,r.ServiceCenter) ='SSP45' AND r.idtransportadora = 1491631999 then 'Itaquera'
			 WHEN isnull(svc.svc_cd_service_center,r.ServiceCenter) ='SSP21' AND r.idtransportadora = 1491631999 then 'São Paulo' 
			else CidadeDistante end as CidadeDistante,
	r.TotalPacotes,
	r.PacotesEntregues,
	r.PacotesPendentes,
	r.PacotesNaoEntregue,
	r.PacotesEntreguesForaAreaEntrega,
	r.PacotesTransferidos,
	r.TempoEmRota,
	r.TempoChegadaAreaEntrega,
	r.TempoAreaEntrega,
	r.PercentualProgresso,
	r.KmTotal,
	r.TempoEmRota * 60.0 TempoEmRotaSec,
	case when PacotesEntregues = 0 then 0 else cast(datediff(second, r.DataPrimeiraEntrega, r.DataUltimaAtualizacaoPacote) as float) / cast(r.PacotesEntregues as float) end SegundosEntreEntregas,
	case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end RotaFinalizada,
	case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 'Finalizada' else 'Em andamento' end StatusGeralRota,
	r.QuantidadePontos,
	r.QuantidadeParadas,
	r.QuantidadeReclamacoes,
	--case when r.QuantidadeAmbulancia > 0 then 1 else 0 end QuantidadeAmbulancia,
	isnull(r.QuantidadeAmbulancia,0) as QuantidadeAmbulancia ,
	r.StatusPrimeiraEntrega,
	r.StatusSegundaEntrega,
	r.DataPrimeiraEntrega,
	r.DataUltimaEntrega,
	r.Cidades,
	r.CidadeReferencia,
	isnull(r.KmColetado,0) KmColetadoMeli,
	r.LinkMapa LinkMapaMeli,
	r.KmColetadoApp KmColetadoAPP,
	r.LinkMapaApp,
    -- r.Ambulancia
	case when r.TipoRota is null then 'Sim' else 'Não' end AmbulanciaFiltro,
	case when r.TipoRota is null then 1 else 0 end Ambulancia,
	r.KmMotorista,
	r.QuantidadeApontamento,
	r.Apuracao,
	format(r.DataHoraInicio, 'HH:mm') AS HoraInicio,

	case when DATEPART(hour,r.DataHoraInicio) <= 12 then 'AM' ELSE 'PM' end Ciclo,
	case when DataReferencia = cast(getdate() as date) and datediff(minute,DataUltimaEntrega,getdate()) > 40 and case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end = 0 then 1 else 0 end AlarmeRotaEntregaAtraso,
	case when DataReferencia = cast(getdate() as date) and datediff(minute,DataUltimaEntrega,getdate()) > 40 and case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end = 0 then 'Atrasos' else 'Sem Atrasos' end AlarmeRotaEntregaAtrasoFiltro,
	r.FaixaPrimeiroUltimoPacote,    
	r.TempoInativo,
    r.tipo,
    'https://envios.adminml.com/logistics/monitoring-distribution/detail/' + cast(r.IdRota as varchar(15)) + '?site=MLB' LogisticsRota
    ,'A: ' + cast(isnull(QuantidadeReclamacoesAbertas,0) as varchar(5)) +  ' | F: ' + cast(isnull(QuantidadeReclamacoesFechadas,0) as varchar(5)) Reclamacores

--Esta condição abaixo é para a visão de alterar o monitoramento MELI de base p/ XPT
    ,case when r.OrigemSaida = '' OR r.OrigemSaida is null then isnull(svc.svc_cd_service_center,r.ServiceCenter) else r.OrigemSaida end CodOrigemSaida
    ,case when r.OrigemSaida = '' OR r.OrigemSaida is null then svc.svc_nm_service_center else  svc.svc_nm_sigla  end DescOrigemSaida

--Esta condicao é para cria uma classificação para ser utilizado no monitoramento MELI
    ,case
        when r.TempoEmRota - r.TempoAreaEntrega <= 30   then    'Até 30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 60   then    '30m a 1h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 90   then    '1h a 1h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 120  then    '1h30m a 2h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 150  then    '2h a 2h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 180  then    '2h30m a 3h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 210  then    '3h a 3h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 240  then    '3h30m a 4h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 270  then    '4h a 4h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 300  then    '4h30m a 5h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 330  then    '5h a 5h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 360  then    '5h30m a 6h'
        when r.TempoEmRota - r.TempoAreaEntrega >  360  then    'Mais que 6h'
            end as ClassificacaoStemOut,
			svc.bss_ds_label,
			isnull(isnull(svc.svc_cd_service_center,r.ServiceCenter) + ' - ' + svc.svc_nm_cidade
							,isnull(svc.svc_cd_service_center,r.ServiceCenter)
					) Svc_Cidade,
	svc.svc_nm_estado as Estado,
	IdTrevo,
	--CidadeDistante,
	case when tlm_cd_risco_ajudante = 'risco' then 'Sim' else 'Não' end as LancRisco,
    LinkPacote,
    KmMapaPacote,
    case 
        when  veiculo.vei_in_frota_fixa = 3     then 'Própria - Veículo da transportadora'
        when  veiculo.vei_in_frota_fixa = 2     then 'Fixa - Veículo alugado'
        when  veiculo.vei_in_frota_fixa = 1     then 'Spot - Veículo do motorista'
        else 'Não informado'        
    end as CategoriaVeiculo,
    TotalPacotes - QuantidadeAmbulancia as PacotesDS,
	cast(isnull(QuantidadeReclamacoesAbertas,0) as varchar(5))+ '/' + cast((isnull(QuantidadeReclamacoesFechadas,0)+isnull(QuantidadeReclamacoesAbertas,0)) as varchar(5)) ReclamacoesAbertasPeloTotalReclamacoes
	,CASE
        WHEN FORMAT(r.DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'TRUE'
        ELSE 'FALSE'
    END AS FlagSEMIDAY,
	r.TotalSacas,
	CASE WHEN ServiceCenter = 'SSP27' THEN OrigemSaida
	ELSE ServiceCenter  end AS NovoXPT,
	TotalPacotes - TotalSacas as PacotesSemSacas,
	
	
		ISNULL(tratativas.PacotesComImagem,0) as PacotesComImagem




from
	tb_ml_rotas r with(nolock)
	join tb_clientes cli with(nolock) on r.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1 and cli.cli_cd_codigo_cliente <> 7
	left join tb_ml_traducoes t1 on r.NivelExperienciaMotorista = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_ml_rotas' and t1.tds_nm_campo = 'NivelExperienciaMotorista'
	left join tb_ml_traducoes t2 on r.StatusRota = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_rotas' and t2.tds_nm_campo = 'StatusRota'
	left join tb_ml_traducoes t3 on r.StatusPrazo = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_rotas' and t3.tds_nm_campo = 'StatusPrazo'
	left join tb_ml_traducoes t4 on r.SubStatusRota = t4.tds_vl_json and t4.tds_nm_tabela = 'tb_ml_rotas' and t4.tds_nm_campo = 'SubStatusRota'
	left join (
    select 
        idrota,
        idtransportadora,
        COUNT(*) as PacotesComImagem
    from 
        tb_tratativas_entregas
    where Imagem is not null
    group by idrota, idtransportadora
) tratativas
on tratativas.idrota = r.IdRota and tratativas.idtransportadora = r.IdTransportadora
		--left join tb_novos_distritos distritos on distritos.nome_distrito = r.cidadedistante

	left join tb_ml_service_center svc
	on r.ServiceCenter = svc.svc_cd_service_center and r.idtransportadora = svc.idtransportadora

	left join (
			select 
			cli_id_logistics as IdTransportadora
			, * 
			from tb_motorista as a with(nolock)
			inner join tb_clientes as b with(nolock)
			on cli_cd_codigo_cliente = mot_cd_cliente
	) as mot
	on r.IdTransportadora = mot.IdTransportadora
	and r.nomemotorista = mot.mot_nm_motorista

	left join tb_ml_service_center svc2 
	on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
	and r.idtransportadora = svc2.idtransportadora

	left join tb_dra_bases b on isnull(svc2.svc_cd_service_center,svc.svc_cd_service_center) = b.dab_cd_service_center and r.IdTransportadora = b.dab_cd_transportadora

	left join (
				select 
					a.tlm_cd_rota
					,a.tlm_cd_risco_ajudante

				from tb_lancamentos_manuais as a
				inner join (
					select 
					tlm_cd_lancamento_manual	
					,tlm_cd_rota
					,ROW_NUMBER() over(partition by tlm_cd_rota order by tlm_cd_lancamento_manual desc) ordem
					from tb_lancamentos_manuais
					where tlm_cd_cliente = 27
					and tlm_cd_risco_ajudante = 'Risco'
					--and tlm_cd_rota = 'AT202405131ORMZ'
				) as b
				on a.tlm_cd_lancamento_manual = b.tlm_cd_lancamento_manual
				and b.ordem = 1
	) as lanc
	on cast(r.idrota as varchar(50)) = lanc.tlm_cd_rota

    --Join com tb_veiculo para trazer o campo vei_in_frota_fixa , com ele categorizo o veiculo como Frota Fixa 1 , Agregado 2 ,Não Inforamdo Null
	left join(

	select 
		 b.cli_id_logistics
		,a.vei_ds_placa
		,isnull(a.vei_in_tipo_frota,0) as  vei_in_frota_fixa
	from  tb_veiculos as a
		inner join tb_clientes as b	on a.vei_cd_cliente = b.cli_cd_codigo_cliente

	) as veiculo
		on r.idtransportadora = veiculo.cli_id_logistics and r.placa = veiculo.vei_ds_placa

	--Esta join abaixo é para a visão de alterar o monitoramento MELI de base p/ XPT
	-- left join (
			--select 
			--	 bss_ds_sigla
			--	,bss_ds_label 
			--	,bss_ds_nome 
			--from tb_bases 
			--where bss_ds_marketplace = 'Mercado Livre'
			--and bss_cd_base <> 7 
			--) c 
			--on r.servicecenter = c.bss_ds_sigla 
			

	where r.excluido = 0
	and StatusRota <> 'planned'
	and r.DataReferencia >= '2024-12-01' --REMOVER, INSERIDO PARPOR CAUSA DE LENTIDÃO
	--and r.idrota = 174194637
GO
