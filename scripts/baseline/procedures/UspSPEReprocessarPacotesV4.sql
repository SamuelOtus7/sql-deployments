-- ============================================================
-- BASELINE: dbo.UspSPEReprocessarPacotesV4
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEReprocessarPacotesV4]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSPEReprocessarPacotesV4]
as 
begin

	SET NOCOUNT ON;

	truncate table tb_spe_pacotes_para_reprocessar_v4

	--Insere rotas que manteve diferença nos indicadores ou que não foram finalizadas
	insert into tb_spe_pacotes_para_reprocessar_v4 (CodigoPacote, IdTransportadora, IdStation)
	select
		--top 10000
        -- p.DataReferencia,
		p.CodigoPacote,
		p.Idtransportadora,
		r.IdStation
	from
		tb_spe_pacotes_v4 p
		join tb_spe_rotas_v4 r on p.CodigoRota = r.CodigoRota
								and p.IdTransportadora = r.IdTransportadora
								and p.DataReferencia = r.DataReferencia
	where
		(
			--c.dac_cd_coleta is null
			--or isnull(p.StatusEntrega,'') <> 'Delivering'
			--or p.URLImagem is null
		
			p.DataAtualizacao > isnull(p.DataAtualizacaoDetalhe,cast('1900-01-01' as date))
		)
		and p.Excluido = 0
		and isnull(p.SubStatus,'') <> 'transferred'
		and p.IdTransportadora <> 20230003
        and p.DataReferencia >= getdate() - 2

    union all

    select 
    CodigoPacote
    ,IdTransportadora
    ,IdStation  
    from vw_pacotes_spe_v4_pendentes
    where DataReferencia >= '2024-07-28'
    -- and IdTransportadora = 20230007
    and IdStation is not null

end
GO
