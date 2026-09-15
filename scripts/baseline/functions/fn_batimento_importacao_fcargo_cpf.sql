-- ============================================================
-- BASELINE: dbo.fn_batimento_importacao_fcargo_cpf
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_batimento_importacao_fcargo_cpf]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_batimento_importacao_fcargo_cpf](@PeriodoPgto int)
returns table
as return

select top 1000000
	   isnull(excel.cpf,irisys.CPF) as CPF,
	   isnull(excel.valor,0) as ValorExcel,
	   isnull(irisys.valor,0) as ValorIrisys,
	   round(isnull(excel.valor,0) - isnull(irisys.valor,0),2) as Delta,
	   abs(round(isnull(excel.valor,0) - isnull(irisys.valor,0),2)) AbsDelta
from (
			select 
					dbo.fc_ExtrairNumeros(CPF) as CPF,
					--sum(cast(replace(replace(ValorTotal,'.','.'),',','.') as decimal(10,2))) as valor
					sum(cast(replace(ValorTotal,',','') as decimal(10,2))) as valor
			from tb_pgto_espelh_temp
			group by dbo.fc_ExtrairNumeros(CPF)
) as excel
full join (
			select dbo.fc_ExtrairNumeros(mot_cpf) as CPF,
				   sum(mtn_vl_nfs) as valor, count(*) as qtde
			from tb_pag_espelhos a
				join tb_usuario b on a.mtn_cd_motorista = b.usr_cd_usuario and b.cli_cd_codigo_cliente = 27
				join tb_motorista c on b.usr_cd_usuario = c.mot_cd_usuario and c.mot_cd_status = 1 and c.mot_cd_cliente = 27
			where mtn_cd_pgto_periodo = @PeriodoPgto
			group by dbo.fc_ExtrairNumeros(mot_cpf)
) as irisys
on Excel.CPF = irisys.CPF
order by AbsDelta desc
GO
