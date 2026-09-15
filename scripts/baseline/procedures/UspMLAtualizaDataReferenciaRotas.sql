-- ============================================================
-- BASELINE: dbo.UspMLAtualizaDataReferenciaRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaDataReferenciaRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLAtualizaDataReferenciaRotas]
as
set nocount on

declare @agora time = getdate(),
	@faixaini time = '00:30:00.0000000',
	@faixafim time = '06:30:00.0000000',
	@dataorigem date = cast(getdate()-1 as date),
	@dataDestino date

set @dataDestino = DATEADD(DAY, 1, @dataorigem)

/*
	update para atulizar a data de referencia dos pacotes que nao concluiram 
	as entregas na data de inicio da rota.
	esta etapa deve ser executada apenas uma vez por dia antes do porcessamento full do SSAS
*/
if @agora between @faixaini and @faixafim
begin
	update a
	set
	a.DataReferencia = @dataDestino
	from tb_ml_rotas as a
	left join (
		select
			IdTransportadora,
			DataReferencia,
			idrota
		from tb_ml_pacotes
		where 1=1
			-- and idrota = 249703420
			and StatusEntrega = 'pending'
			and datareferencia = @dataorigem
		group by IdTransportadora, DataReferencia, idrota
	) as b
	on a.DataReferencia = b.DataReferencia
	and a.IdTransportadora = b.IdTransportadora
	and a.idrota = b.idrota

	inner join (
		SELECT
			cli.cli_id_logistics,
			prm_ds_valor
		FROM tb_parametros AS a
			INNER JOIN tb_clientes AS cli
			ON cli.cli_cd_codigo_cliente = a.prm_cod_cliente
			INNER JOIN tb_lista AS lst
			ON a.prm_ds_valor = lst.lst_cd_lista
		WHERE prm_nm_parametro = 'Data do Monitoramento'
		and cli_cd_codigo_cliente <> 7
		and cli_in_ativo = 1
		and prm_ds_valor = 1162
	) as c
	on c.cli_id_logistics = a.IdTransportadora


	where 1=1
	-- and a.idrota = 249703420
	and a.datareferencia = @dataorigem
	and a.StatusRota = 'active'
end
GO
