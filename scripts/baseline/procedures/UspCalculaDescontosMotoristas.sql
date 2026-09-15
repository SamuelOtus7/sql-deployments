-- ============================================================
-- BASELINE: dbo.UspCalculaDescontosMotoristas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspCalculaDescontosMotoristas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[UspCalculaDescontosMotoristas] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin
	
	SET NOCOUNT ON
	
	delete tb_fin_descontos_motoristas
	where IdTransportadora in (
	select cli_cd_codigo_cliente
	from tb_clientes as cli
	where cli.cli_id_logistics = @IdTransportadora)
	and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	
	delete tb_fin_descontos_motoristas
	where IdTransportadora = @IdTransportadora
	and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena


	insert into tb_fin_descontos_motoristas  (IdTransportadora, Ano, Mes, Quinzena, IdRota, DataReferencia, ServiceCenter, Motorista, TipoVeiculo, Ciclo, Desconto, Motivo, IdPacote)
	select
		cli_id_logistics IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		p.IdRota IdRota,
		p.DataReferencia,
		r.ServiceCenter,
		r.NomeMotorista Motorista,
		r.TipoVeiculo,
		case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end CicloPM,
		p.Total,
		p.Descricao Motivo,
		p.IdPacote
	from
		tb_fin_prefatura_descontos p
		join vw_rotas r on p.IdRota = r.IdRota and p.IdTransportadora = r.IdTransportadora
		left join DimData dt on p.DataReferencia = dt.Data
		left join tb_fin_prefatura pre on r.IdTransportadora = pre.IdTransportadora
													and r.IdRota = pre.IdRota
													and pre.Quinzena = @Quinzena
													and pre.Ano = @Ano
													and pre.Mes = @Mes
			
		inner join  tb_clientes as cli
		on p.idtransportadora  = cli.cli_id_logistics

	where
		p.IdTransportadora = @IdTransportadora 
		and p.Ano = @Ano 
		and p.Mes = @Mes 
		and p.Quinzena = @Quinzena
		and cli.cli_cd_codigo_cliente <> 7

end
GO
