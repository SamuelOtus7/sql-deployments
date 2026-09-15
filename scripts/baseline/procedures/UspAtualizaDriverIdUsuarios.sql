-- ============================================================
-- BASELINE: dbo.UspAtualizaDriverIdUsuarios
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaDriverIdUsuarios]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspAtualizaDriverIdUsuarios]
as
begin

	
	--01 atualiza cruzando cpf e e-mail
	update
		u
	set
		u.usr_cd_driverid = m2.IdMotorista
	from
		tb_usuario u with(nolock)
		join tb_clientes c with(nolock) on u.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
										and c.cli_cd_codigo_cliente <> 7
		join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario 
										and u.cli_cd_codigo_cliente = m.mot_cd_cliente
										and m.mot_cd_status = 1
										and m.mot_cpf <> ''
		join tb_ml_motoristas m2 with(nolock) on m.mot_cpf = m2.CPF
											and c.cli_id_logistics = m2.IdTransportadora
		join (
				select
					IdTransportadora
					,CPF
					,max(IdMotorista) IdMotorista
				from
					tb_ml_motoristas
				where
					Ativo = 1
					and CPF <> ''
				group by
					IdTransportadora
					,CPF
			) m3 on m2.IdMotorista = m3.IdMotorista and m2.IdTransportadora = m3.IdTransportadora
		join tb_ml_motoristas m4 with(nolock) on m3.IdMotorista = m4.IdMotorista 
											and m3.IdTransportadora = m4.IdTransportadora
											and u.usr_ds_email = m4.Email
	where
		u.usr_in_ativo = 1
		and u.usr_cd_driverid is null
		and u.usr_in_motorista = 1
		and DIFFERENCE(
			DBO.fn_remove_acentuacao(u.usr_nm_usuario), 
			DBO.fn_remove_acentuacao(m2.Nome)
		) >= 4
		and u.usr_dh_criacao >= dateadd(day,-3,cast(getdate() as date))
		and not exists (select 
							1 
						from 
							tb_usuario usu 
						where 
							usu.usr_in_ativo = 1
							and u.usr_cd_driverid = usu.usr_cd_driverid
							and u.cli_cd_codigo_cliente = usu.cli_cd_codigo_cliente
						)

	

	--atualiza cruzando cpf
	update
		u
	set
		u.usr_cd_driverid = m2.IdMotorista
	from
		tb_usuario u with(nolock)
		join tb_clientes c with(nolock) on u.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
										and c.cli_cd_codigo_cliente <> 7
		join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario 
										and u.cli_cd_codigo_cliente = m.mot_cd_cliente
										and m.mot_cd_status = 1
										and m.mot_cpf <> ''
		join tb_ml_motoristas m2 with(nolock) on m.mot_cpf = m2.CPF
											and c.cli_id_logistics = m2.IdTransportadora
		join (
				select
					IdTransportadora
					,CPF
					,max(IdMotorista) IdMotorista
				from
					tb_ml_motoristas
				where
					Ativo = 1
					and CPF <> ''
				group by
					IdTransportadora
					,CPF
			) m3 on m2.IdMotorista = m3.IdMotorista and m2.IdTransportadora = m3.IdTransportadora
		join (
			select
				mot_cd_cliente
				,mot_cpf
			from
				tb_motorista
			where
				mot_cd_status = 1
				and mot_cpf <> ''
			group by
				mot_cd_cliente
				,mot_cpf
			having
				count(1) = 1
		) m4 on m.mot_cd_cliente = m4.mot_cd_cliente and m.mot_cpf = m4.mot_cpf --remove motoristas ativos que estiverem com mesmo cpf
	where
		u.usr_in_ativo = 1
		and u.usr_cd_driverid is null
		and u.usr_in_motorista = 1
		and DIFFERENCE(
			DBO.fn_remove_acentuacao(u.usr_nm_usuario), 
			DBO.fn_remove_acentuacao(m2.Nome)
		) >= 4
		and u.usr_dh_criacao >= dateadd(day,-3,cast(getdate() as date))
		and not exists (select 
							1 
						from 
							tb_usuario usu 
						where 
							usu.usr_in_ativo = 1
							and u.usr_cd_driverid = usu.usr_cd_driverid
							and u.cli_cd_codigo_cliente = usu.cli_cd_codigo_cliente
						)


	--atualiza cruzando email
	update
		u
	set
		u.usr_cd_driverid = m.IdMotorista
	from
		tb_usuario u with(nolock)
		join tb_clientes c with(nolock) on u.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
										and c.cli_cd_codigo_cliente <> 7	
		join tb_ml_motoristas m witH(nolock) on u.usr_ds_email = m.Email
											and c.cli_id_logistics = m.IdTransportadora
	where
		u.usr_in_ativo = 1
		and u.usr_cd_driverid is null
		and u.usr_in_motorista = 1
		and DIFFERENCE(
			DBO.fn_remove_acentuacao(u.usr_nm_usuario), 
			DBO.fn_remove_acentuacao(m.Nome)
		) >= 4
		and u.usr_dh_criacao >= dateadd(day,-3,cast(getdate() as date))
		and not exists (select 
							1 
						from 
							tb_usuario usu 
						where 
							usu.usr_in_ativo = 1
							and u.usr_cd_driverid = usu.usr_cd_driverid
							and u.cli_cd_codigo_cliente = usu.cli_cd_codigo_cliente
						)


	--verificar depois com calma se podemos criar essa update (Atualizado em 25/05/2026 por Saulo Barros)
	/*
	select
		u.usr_nm_usuario
		,m.Nome
	from
		tb_usuario u with(nolock)
		join tb_clientes c with(nolock) on u.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
		join tb_ml_motoristas m with(nolock) on u.usr_cd_driverid = m.IdMotorista
											and c.cli_id_logistics = m.IdTransportadora
	where
		u.usr_in_ativo = 1
		and u.usr_cd_driverid is not null
		and DIFFERENCE(
			DBO.fn_remove_acentuacao(trim(replace(translate(u.usr_nm_usuario, '0123456789', '##########'),'#',''))), 
			DBO.fn_remove_acentuacao(trim(replace(translate(m.Nome, '0123456789', '##########'),'#','')))
		) < 4
	
	update
		u
	set
		usr_cd_driverid = null
	from
		tb_usuario u with(nolock)
		join tb_clientes c with(nolock) on u.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
		join tb_ml_motoristas m with(nolock) on u.usr_cd_driverid = m.IdMotorista
											and c.cli_id_logistics = m.IdTransportadora
	where
		u.usr_in_ativo = 1
		and u.usr_cd_driverid is not null
		and DIFFERENCE(
			DBO.fn_remove_acentuacao(trim(replace(translate(u.usr_nm_usuario, '0123456789', '##########'),'#',''))), 
			DBO.fn_remove_acentuacao(trim(replace(translate(m.Nome, '0123456789', '##########'),'#','')))
		) < 4
	*/

end
GO
