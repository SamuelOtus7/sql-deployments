-- ============================================================
-- BASELINE: dbo.sp_teste
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_teste]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_teste] (
 @idtransportadoraML int
,@Ano 				int
,@Mes 				int
,@Quinzena 			int
,@idrota 			int
,@datareff			date
) as 



insert into tb_teste
select 
 @idtransportadoraML
,@Ano 				
,@Mes 				
,@Quinzena 			
,@idrota 		
,@datareff

--select * from tb_teste
GO
