-- ============================================================
-- BASELINE: dbo.UspSPELoadMotoristasCPF
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadMotoristasCPF]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPELoadMotoristasCPF]  (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@IdMotorista int
)
as
begin
	
	SET NOCOUNT ON;

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')

	drop table if exists #motoristascpf
	create table #motoristascpf (
		IdMotorista int not null,
		IdTransportadora int,
		CPF VARCHAR(MAX)
	)

	INSERT INTO #motoristascpf
	SELECT 
		 @IdMotorista
		,@IdTransportadora
		,CPF
		
	FROM 
		OPENJSON (@JsonData)
	WITH 
		(
			 CPF varchar(60) '$.data_detail'
		)

	
merge tb_spe_motoristas as m
using #motoristascpf as i
		ON m.IdMotorista = i.IdMotorista
		--and m.IdTransportadora = i.IdTransportadora

when matched and

(
(m.CPF <> i.CPF or m.CPF is null)
)

then

update
set
	m.CPF = i.CPF;

end;


--select *  from #motoristascpf 
--select *  from tb_spe_motoristas as m
--inner join #motoristascpf as i
--		ON m.IdMotorista = i.IdMotorista
--		and (m.CPF <> i.CPF or m.CPF is null)
GO
