-- ============================================================
-- BASELINE: dbo.vw_rotas_TESTE
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_TESTE]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[vw_rotas_TESTE]
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
	case when svc.svc_in_ambulancia = 1 and r.TipoRota is null then svc.svc_ds_origem_base else r.OrigemSaida end OrigemSaida,
	r.TipoRota,
	r.TipoVeiculo,
	r.NomeMotorista,
	mot_cd_motorista as IdMotorista,
	mot_cd_usuario as Codigo_usuario_motorista,
	isnull(r.Placa,'-') as Placa,
	t1.tds_ds_traducao NivelExperienciaMotorista,
	r.IdNivelMotorista,
	r.NivelMotorista,
	r.QuantidadePacotesTransportados,
	r.PercentualEntregasBemSucedidas,
	r.PercentualEntregasSemRelamacaoes,
	r.PossuiAjudante,
	case when r.PossuiAjudante = 1 then 'Sim' else 'Não' end Ajudante,
    isnull(case when KmColetadoApp = 0 then KmMapaPacote else KmColetadoApp end,1)  AS KmColetado,
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
	case when DATEPART(hour,r.DataHoraInicio) < 12 then 'AM' ELSE 'PM' end Ciclo,

-- inclusão do indicador de tempo desde a ultima rota para corrigir o alerta no monitoramento de entregas
	CASE WHEN r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos OR r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue OR (r.StatusRota = 'planned' AND r.DataReferencia < CAST(GETDATE() AS DATE)) THEN 0 
		 WHEN DataReferencia = CAST(GETDATE() AS DATE) AND DATEDIFF(MINUTE, DataUltimaEntrega, GETDATE()) > 60 THEN 2 
		 WHEN DataReferencia = CAST(GETDATE() AS DATE) AND DATEDIFF(MINUTE, DataUltimaEntrega, GETDATE()) > 40 THEN 1 ELSE 0 END AS AlarmeRotaEntregaAtraso,
	
	case when DataReferencia = cast(getdate() as date) and datediff(minute,DataUltimaEntrega,getdate()) > 40 and case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end = 0 then 'Atrasos' else 'Sem Atrasos' end AlarmeRotaEntregaAtrasoFiltro,
	r.FaixaPrimeiroUltimoPacote,    
	r.TempoInativo,
    'LM' tipo,
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
	,vei_Cd_ano
	,r.DataAtualizacao -- CAMPO USADO NA API DE MONITORAMENTO
	,r.EnderecosVisitados
	,r.TeveAcaoGps
	,svc.svc_nm_region
	,ISNULL(QuantidadeReclamacoesAbertas,0) AS QTD_Reclamacoes_em_aberto
	,ISNULL(QuantidadeReclamacoes,0) as QTD_Reclamacoes_total
	,vei_dh_criacao
	,r.QuantidadePnr
	,AmbulanciaStatus		= ambL.[amb_status]
	,AmbulanciaPagamento	= ambL.[amb_pagamento]
	,AmbulanciaIdMotorista	= ambL.[amb_id_motorista]
from
	tb_ml_rotas r with (nolock)
	join tb_clientes cli with (nolock) on r.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1 and cli.cli_cd_codigo_cliente <> 7
	left join tb_ml_traducoes t1 with (nolock) on r.NivelExperienciaMotorista = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_ml_rotas' and t1.tds_nm_campo = 'NivelExperienciaMotorista'
	left join tb_ml_traducoes t2 with (nolock) on r.StatusRota = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_rotas' and t2.tds_nm_campo = 'StatusRota'
	left join tb_ml_traducoes t3 with (nolock) on r.StatusPrazo = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_rotas' and t3.tds_nm_campo = 'StatusPrazo'
	left join tb_ml_traducoes t4 with (nolock) on r.SubStatusRota = t4.tds_vl_json and t4.tds_nm_tabela = 'tb_ml_rotas' and t4.tds_nm_campo = 'SubStatusRota'
	left join (
    select 
        idrota,
        idtransportadora,
        COUNT(*) as PacotesComImagem
    from 
        tb_tratativas_entregas with (nolock)
    where Imagem is not null
    group by idrota, idtransportadora
) tratativas
on tratativas.idrota = r.IdRota and tratativas.idtransportadora = r.IdTransportadora
		--left join tb_novos_distritos distritos on distritos.nome_distrito = r.cidadedistante

	left join tb_ml_service_center svc with (nolock)
	on r.ServiceCenter = svc.svc_cd_service_center and r.idtransportadora = svc.idtransportadora

	left join (
			select 
			cli_id_logistics as IdTransportadora
			, mot_nm_motorista
			, max(mot_cd_motorista) as mot_cd_motorista -- tratamento para evitar duplicidade por erro de cadastro
			, max(mot_cd_usuario) as mot_cd_usuario
			from tb_motorista as a with (nolock)
			inner join tb_clientes as b with (nolock)
			on cli_cd_codigo_cliente = mot_cd_cliente
			group by cli_id_logistics,
					 mot_nm_motorista
	) as mot
	on r.IdTransportadora = mot.IdTransportadora
	and r.nomemotorista = mot.mot_nm_motorista

	left join tb_ml_service_center svc2 with (nolock)
	on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
	and r.idtransportadora = svc2.idtransportadora

	left join tb_dra_bases b with (nolock) on isnull(svc2.svc_cd_service_center,svc.svc_cd_service_center) = b.dab_cd_service_center and r.IdTransportadora = b.dab_cd_transportadora

	left join (
				select 
					a.tlm_cd_rota
					,a.tlm_cd_risco_ajudante

				from tb_lancamentos_manuais as a with (nolock)
				inner join (
					select 
					tlm_cd_lancamento_manual	
					,tlm_cd_rota
					,ROW_NUMBER() over(partition by tlm_cd_rota order by tlm_cd_lancamento_manual desc) ordem
					from tb_lancamentos_manuais with (nolock)
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
		,vei_Cd_ano
		,isnull(a.vei_in_tipo_frota,0) as  vei_in_frota_fixa
		,vei_dh_criacao
	from  tb_veiculos as a with (nolock)
		inner join tb_clientes as b with (nolock) on a.vei_cd_cliente = b.cli_cd_codigo_cliente

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

-- Felipe Oliveira - 26/03/2025 - esse Join para trazer dados de ambulancia do Looker 

LEFT JOIN (
    SELECT 
         amb_id_rota,
         amb_data,
         amb_status,
         amb_pagamento,
         amb_id_motorista
    FROM (SELECT  amb_id_rota,  amb_data, amb_status, amb_pagamento, amb_id_motorista,
             ROW_NUMBER() OVER (PARTITION BY amb_id_rota ORDER BY amb_data DESC) AS rn
         FROM [dbo].[tb_looker_ambulancias] WITH (NOLOCK)
        --WHERE amb_id_rota = 218963480
    ) AS sub
    WHERE rn = 1
) AS ambL

on r.DataReferencia = ambL.[amb_data]
and cast(r.idrota as varchar(50)) = ambL.[amb_id_rota]


	where r.excluido = 0
	and StatusRota <> 'planned'
	and (TotalPacotes > 0 or PacotesTransferidos > 0)
	--and DataReferencia >= '2025-03-01'
	--and servicecenter  <> 'SC_ZS'
	--and r.idrota = 174194637

union all

select
	IdTransportadora
	,Id
	,IdRota
	,DataReferencia
	,null DataHoraInicio
	,Status StatusRota
	,null SubStatusRota
	,null StatusPrazo
	,OrigemSaida ServiceCenter
	,NomeOrigemSaida NomeServiceCenter
	,OrigemSaida Base
	,null CidadeBase
	,null TipoOrigemSaida
	,OrigemSaida
	,TipoRota
	,TipoVeiculo
	,NomeMotorista
	,IdMotorista
	,null Codigo_usuario_motorista
	,PlacaVeiculo
	,null NivelExperienciaMotorista
	,null IdNivelMotorista
	,null NivelMotorista
	,null QuantidadePacotesTransportados
	,null PercentualEntregasBemSucedidas
	,null PercentualEntregasSemRelamacaoes
	,null PossuiAjudante
	,'Não' Ajudante
	,0 KmColetado
	,'-' LinkMapa
	,'Não' UsouAPP
	,UsuarioDA
	,null CidadeDistante
	,QuantidadePacotesColetados TotalPacotes
	,0 PacotesEntregues
	,0 PacotesPendentes
	,0 PacotesNaoEntregue
	,0 PacotesEntreguesForaAreaEntrega
	,null PacotesTransferidos
	,0 TempoEmRota
	,0 TempoChegadaAreaEntrega
	,0 TempoAreaEntrega
	,0 PercentualProgresso
	,0 KmTotal
	,0 TempoEmRotaSec
	,null SegundosEntreEntregas
	,1 RotaFinalizada
	,'Finalizada' StatusGeralRota
	,0 QuantidadePontos
	,QuantidadeParadas
	,0 QuantidadeReclamacoes
	,0 QuantidadeAmbulancia
	,null StatusPrimeiraEntrega
	,null StatusSegundaEntrega
	,null DataPrimeiraEntrega
	,null DataUltimaEntrega
	,null Cidades
	,null CidadeReferencia
	,null KmColetadoMeli
	,null LinkMapaMeli
	,null KmColetadoAPP
	,null LinkMapaApp
	,null AmbulanciaFiltro
	,null Ambulancia
	,null KmMotorista
	,null QuantidadeApontamento
	,null Apuracao
	,null HoraInicio
	,null Ciclo
	,null AlarmeRotaEntregaAtraso
	,null AlarmeRotaEntregaAtrasoFiltro
	,null FaixaPrimeiroUltimoPacote
	,0 TempoInativo
	,'FM' tipo
	,null LogisticsRota
	,null Reclamacores
	,null CodOrigemSaida
	,null DescOrigemSaida
	,null ClassificacaoStemOut
	,null bss_ds_label
	,null Svc_Cidade
	,null Estado
	,null IdTrevo
	,null LancRisco
	,null LinkPacote
	,null KmMapaPacote
	,null CategoriaVeiculo
	,null PacotesDS
	,null ReclamacoesAbertasPeloTotalReclamacoes
	,null FlagSEMIDAY
	,null TotalSacas
	,null NovoXPT
	,null PacotesSemSacas
	,null PacotesComImagem
	,null vei_Cd_ano
	,null DataAtualizacao
	,null EnderecosVisitados
	,null TeveAcaoGps
	,null svc_nm_region
	,null QTD_Reclamacoes_em_aberto
	,null QTD_Reclamacoes_total
	,null vei_dh_criacao
	,null QuantidadePnr
	,null AmbulanciaStatus		 
	,null AmbulanciaPagamento	 
	,null AmbulanciaIdMotorista	 
from
	tb_ml_fm_rotas with (nolock)
where
	Excluido = 0
	
union all


select
	IdTransportadora
	,Id
	,IdRota
	,DataReferencia
	,DataHoraInicio
	,'Close' StatusRota
	,null SubStatusRota
	,null StatusPrazo
	,ServiceCenter ServiceCenter
	,ServiceCenter NomeServiceCenter
	,ServiceCenter Base
	,null CidadeBase
	,null TipoOrigemSaida
	,ServiceCenter OrigemSaida
	,'MeliOne'TipoRota
	,TipoVeiculo
	,NomeMotorista
	,null IdMotorista
	,null Codigo_usuario_motorista
	,PlacaVeiculo
	,null NivelExperienciaMotorista
	,null IdNivelMotorista
	,null NivelMotorista
	,null QuantidadePacotesTransportados
	,null PercentualEntregasBemSucedidas
	,null PercentualEntregasSemRelamacaoes
	,null PossuiAjudante
	,'Não' Ajudante
	,0 KmColetado
	,'-' LinkMapa
	,'Não' UsouAPP
	,UsuarioDA
	,null CidadeDistante
	,0 TotalPacotes
	,0 PacotesEntregues
	,0 PacotesPendentes
	,0 PacotesNaoEntregue
	,0 PacotesEntreguesForaAreaEntrega
	,null PacotesTransferidos
	,0 TempoEmRota
	,0 TempoChegadaAreaEntrega
	,0 TempoAreaEntrega
	,0 PercentualProgresso
	,0 KmTotal
	,0 TempoEmRotaSec
	,null SegundosEntreEntregas
	,1 RotaFinalizada
	,'Finalizada' StatusGeralRota
	,0 QuantidadePontos
	,0 QuantidadeParadas
	,0 QuantidadeReclamacoes
	,0 QuantidadeAmbulancia
	,null StatusPrimeiraEntrega
	,null StatusSegundaEntrega
	,null DataPrimeiraEntrega
	,null DataUltimaEntrega
	,null Cidades
	,null CidadeReferencia
	,null KmColetadoMeli
	,null LinkMapaMeli
	,null KmColetadoAPP
	,null LinkMapaApp
	,null AmbulanciaFiltro
	,null Ambulancia
	,null KmMotorista
	,null QuantidadeApontamento
	,null Apuracao
	,null HoraInicio
	,null Ciclo
	,null AlarmeRotaEntregaAtraso
	,null AlarmeRotaEntregaAtrasoFiltro
	,null FaixaPrimeiroUltimoPacote
	,0 TempoInativo
	,'MO' tipo
	,null LogisticsRota
	,null Reclamacores
	,null CodOrigemSaida
	,null DescOrigemSaida
	,null ClassificacaoStemOut
	,null bss_ds_label
	,null Svc_Cidade
	,null Estado
	,null IdTrevo
	,null LancRisco
	,null LinkPacote
	,null KmMapaPacote
	,null CategoriaVeiculo
	,null PacotesDS
	,null ReclamacoesAbertasPeloTotalReclamacoes
	,null FlagSEMIDAY
	,null TotalSacas
	,null NovoXPT
	,null PacotesSemSacas
	,null PacotesComImagem
	,null vei_Cd_ano
	,null DataAtualizacao
	,null EnderecosVisitados
	,null TeveAcaoGps
	,null svc_nm_region
	,null QTD_Reclamacoes_em_aberto
	,null QTD_Reclamacoes_total
	,null as vei_dh_criacao
	,NULL AS QuantidadePnr
	,null AmbulanciaStatus		 
	,null AmbulanciaPagamento	 
	,null AmbulanciaIdMotorista	 
from
	[tb_ml_mo_rotas] with (nolock)
where
	Excluido = 0
GO
