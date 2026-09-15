-- ============================================================
-- BASELINE: dbo.UspDimTempo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspDimTempo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--==================================================
-- Autor: Vitor Ferreira
-- Data de Criação: 29/08/2021
-- Descrição: Carrega dimensão de Tempo
--==================================================
create procedure [dbo].[UspDimTempo]

as

truncate table DimTempo 

declare @tempo time = '00:00'
while @tempo <= '23:45'
begin
	insert into DimTempo 
	values 
	(
		datepart(hour,@tempo) * 100 + datepart(minute,@tempo),
		@tempo,
		datepart(hour,@tempo),
		datepart(minute,@tempo),
		case  
			when datepart(hour,@tempo) < 6 then 'Madrugada'
			when datepart(hour,@tempo) < 12 then 'Manha'
			when datepart(hour,@tempo) < 18 then 'Tarde'
			else 'Noite'
		end
	)

	set @tempo = dateadd(minute,case when @tempo <> '23:45' then 15 else 1 end,@tempo)

end
GO
