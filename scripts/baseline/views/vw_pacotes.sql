-- ============================================================
-- BASELINE: dbo.vw_pacotes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_pacotes]
as
SELECT 
	p.IdTransportadora
	,cast(p.DataReferencia as datetime) DataReferencia
	,p.Id
	,p.IdPacote IdEntrega
	,p.IdRota
	,r.Id as IdInternoRota
	,p.IdRotaOrigem
	,p.IdRotaDestino
	,case when p.IdRotaOrigem is not null or p.IdRotaDestino is not null then 1 else 0 end Ambulancia
	,p.QuantidadePontosParada Pontos
	,p.SequenciaParada OrdemEntrega
	,case
        --Regra alinhada com UspMLAtualizaDeltaIndicadoresRotas (PacotesNaoEntregues), usando tb_ml_status_entrega_traducao
        when tred.StatusEntregaTraduzido = 'Não entregue'
             and isnull(p.SubStatus,'') <> 'transferred'
             and p.Status not in ('stop', 'stop_place_prepared')
             and isnull(p.TipoPonto,'') <> 'pickup'
            then 'Não Entregue'
        --not_delivered que não atende aos filtros da procedure (pickup/stop/stop_place_prepared)
        when tred.StatusEntregaTraduzido = 'Não entregue'
             and isnull(p.SubStatus,'') <> 'transferred'
            then 'Coletado em Rota'
        else t.tds_ds_traducao
	 end as StatusEntrega
	,case  
        when t3.tds_ds_traducao = 'Endereço Ruim' then 'Endereço inválido'
        when t3.tds_ds_traducao = 'Erro de Rota' then 'Fora de Área'
        else isnull(t3.tds_ds_traducao,'Não Categorizado') end  SubStatus

	,t2.tds_ds_traducao TipoEndereco
	,p.EnderecoParada
	,p.LatitudeEnderecoParada
	,p.LongitudeEnderecoParada
	,case when trim(t.tds_ds_traducao) in('Entregue','Entregue - Place') or t.tds_ds_traducao like 'Transferido para a rota%' then 'Sucesso'
		     when trim(t.tds_ds_traducao) in ('Chegando ao Destino','Pendente','Em rota de entrega','Para expedir','Coletado')
		           or (tred.StatusEntregaTraduzido = 'Não entregue' and isnull(p.SubStatus,'') <> 'transferred'
		               and (p.Status in ('stop', 'stop_place_prepared') or isnull(p.TipoPonto,'') = 'pickup'))
		          then 'Em Andamento'
			 else 'Insucesso'
		end as StatusGeralEntrega
	,p.DataHoraEntrega
	,left(cast(cast(p.DataHoraEntrega as time) as varchar),5) HoraEvento
	,tm.SkTempo
	,p.NomeEtiqueta Etiqueta
	,p.QuantidadeReclamacoes
	,p.DataAtualizacao
    ,'https://envios.adminml.com/logistics/package-management/package/' + cast(P.IdPacote as varchar(30)) as LogisticsPacote
	,p.Cidade
	,pnr.IdReclamacao as IdPNR
	,pnr.Status as StatusPNR
	,    CASE WHEN pnr.IdPacote IS NOT NULL THEN 1 ELSE 0 END AS FlagPNR
	,p.cep


FROM 
	tb_ml_pacotes p with(nolock)
	inner join tb_ml_rotas as r with(nolock) on r.IdRota = p.IdRota
									--	and r.DataReferencia = p.DataReferencia
									and r.IdTransportadora = p.IdTransportadora and r.Excluido = 0 
									and 	 r.StatusRota <> 'planned'

	join tb_clientes cli with(nolock) on r.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1 and cli.cli_cd_codigo_cliente <> 7
	join (
			select 
				SkTempo,
				Hora,
				Minuto MinutoInicial,
				Minuto + 15 MinutoFinal
			from
				DimTempo t
		) tm on DATEPART(hour,p.DataHoraEntrega) = tm.Hora and DATEPART(MINUTE,p.DataHoraEntrega) >= tm.MinutoInicial  and DATEPART(MINUTE,p.DataHoraEntrega) < tm.MinutoFinal
	
	left join tb_ml_traducoes t on p.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
	left join tb_ml_traducoes t2 on p.TipoEndereco = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_pacotes' and t2.tds_nm_campo = 'TipoEndereco'
	left join tb_ml_traducoes t3 on p.SubStatus = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_pacotes' and t3.tds_nm_campo = 'SubStatus'
	left join tb_ml_pnr pnr on pnr.IdPacote = p.IdPacote
	left join tb_ml_status_entrega_traducao tred on tred.TenantID = cli.cli_cd_codigo_cliente
		and tred.StatusEntrega = p.StatusEntrega
		and (tred.SubStatus = p.SubStatus or (tred.SubStatus is null and p.SubStatus is null))
where
	p.Excluido = 0
	 and (p.DataReferencia) >= DATEADD(MONTH, -6, GETDATE()) and (p.DataReferencia) <= DATEADD(HOUR, -1, GETDATE())
	--and p.idtransportadora  = 288216524

	
GO
