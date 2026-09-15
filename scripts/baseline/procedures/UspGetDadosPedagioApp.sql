-- ============================================================
-- BASELINE: dbo.UspGetDadosPedagioApp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDadosPedagioApp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[UspGetDadosPedagioApp]
(
    @CodMotorista int,
	@Tipo tinyint, -- 1 para CodigoUsuario e 2 para Matricula
	@IdRota varchar(50) = ''
)
as
--
--exec UspGetDadosPedagioApp 9525, 1;  --CodigoUsuario
--exec UspGetDadosPedagioApp 9525, 2;  --Matricula

create table #return
(
    Rota varchar(30),
    Base varchar(30),
    Matricula varchar(10),
	Nome varchar(150),
    Dispacher varchar(150),
	Data date
)

if @CodMotorista = 9525
begin
	set @CodMotorista = 6687
end

        insert into #return
        select top 1 cast(IdRota as varchar) as Rota,
            ServiceCenter as Base,
            users.usr_cd_usuario as Matricula,
			users.usr_nm_usuario as Nome,
            '' as Dispacher,
			rotas.DataReferencia as Data
        from tb_ml_rotas as rotas
            inner join tb_usuario as users 
            on rotas.NomeMotorista = users.usr_nm_usuario
            inner join tb_clientes as clientes 
            on users.cli_cd_codigo_cliente = clientes.cli_cd_codigo_cliente
            and rotas.IdTransportadora = clientes.cli_id_logistics
        where (rotas.DataReferencia = cast(getdate() as date) or (rotas.IdRota = @IdRota and @IdRota <> ''))
              and rotas.Excluido = 0
			  and users.usr_cd_usuario = @CodMotorista 

        if not exists (select Rota from #return)
        begin
        insert into #return
            select top 1 CodigoRota as Rota,
                stations.NomeStation as Base,
                users.usr_cd_usuario as Matricula,
				users.usr_nm_usuario as Nome,
                '' as Dispacher,
				rotas.DataReferencia as Data
            from tb_spe_rotas_v5 as rotas
                inner join tb_spe_motoristas as drivers
                on rotas.IdMotorista = drivers.IdMotorista
                inner join tb_spe_station as stations
                on rotas.IdStation = stations.IdStation
                inner join tb_usuario as users 
                on drivers.NomeMotorista = users.usr_nm_usuario
                inner join tb_clientes as clientes 
                on users.cli_cd_codigo_cliente = clientes.cli_cd_codigo_cliente
                and rotas.IdTransportadora = clientes.cli_id_logistics
            where users.usr_cd_usuario = @CodMotorista 
                  and (rotas.DataReferencia = cast(getdate() as date) or (rotas.CodigoRota = @IdRota and @IdRota <> ''))
                  and rotas.Excluido = 0
        end
		if not exists (select Rota from #return)
        begin
			insert into #return
			select null as Rota,
				null as Base,
				usr_cd_usuario as Matricula,
				usr_nm_usuario as Nome,
				'' as Dispacher,
				cast(getdate() as date) as Data
			from tb_usuario 
			where usr_cd_usuario = @CodMotorista
		end

    select *
    from #return


GO
