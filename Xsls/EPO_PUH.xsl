<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mstns="KartaEPO/2018/07/15"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    exclude-result-prefixes="mstns ds">

	<xsl:output method="html" indent="yes" encoding="UTF-8"/>

	<!-- FORMAT DATY -->
	<xsl:template name="format-date">
		<xsl:param name="datetime"/>
		<xsl:if test="string-length(normalize-space($datetime)) &gt; 0">
			<xsl:value-of select="substring($datetime,1,10)"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="substring($datetime,12,8)"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<html>
			<head>
				<meta charset="UTF-8"/>
				<title>Karta EPO</title>
				<style>
					body { font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px; }
					h1 { color:#1a4d80; }
					h2 { background:#e6f2ff; padding:6px 10px; border-radius:5px; margin-top:25px; }
					table { border-collapse: collapse; width: 90%; margin-bottom: 25px; background: #fff; box-shadow: 0 0 5px #ccc;}
					th, td { border: 1px solid #ccc; padding: 8px; text-align: left; vertical-align: top; }
					th { background-color: #f2f2f2; width: 25%; }
					.signature { border:1px solid #888; padding:10px; background:#fafafa; display:inline-block; margin-top:10px; }
					.signature img { max-width:400px; display:block; margin-bottom:5px; }
					.sig-date { font-size:12px; color:#555; text-align:center; }
				</style>
			</head>
			<body>

				<h1>Karta EPO</h1>

				<xsl:apply-templates select="mstns:KartaEpo"/>

			</body>
		</html>
	</xsl:template>

	<xsl:template match="mstns:KartaEpo">

		<h2>Dane ogólne</h2>
		<table>
			<tr>
				<th>Data utworzenia karty</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataUtworzenia"/>
					</xsl:call-template>
				</td>
			</tr>
		</table>

		<xsl:apply-templates select="mstns:Przesylka"/>
		<xsl:apply-templates select="mstns:PrzesylkaPodpis"/>

	</xsl:template>

	<!-- PRZESYŁKA -->
	<xsl:template match="mstns:Przesylka">

		<table>

			<xsl:if test="string-length(normalize-space(mstns:IdPrzesylki)) &gt; 0">
				<tr>
					<th>Id przesyłki</th>
					<td>
						<xsl:value-of select="mstns:IdPrzesylki"/>
					</td>
				</tr>
			</xsl:if>

			<tr>
				<th>Data nadania</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataNadania"/>
					</xsl:call-template>
				</td>
			</tr>

			<xsl:if test="string-length(normalize-space(mstns:DataPisma)) &gt; 0">
				<tr>
					<th>Data pisma</th>
					<td>
						<xsl:call-template name="format-date">
							<xsl:with-param name="datetime" select="mstns:DataPisma"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>

			<tr>
				<th>Adresat</th>
				<td>
					<xsl:value-of select="mstns:Adresat/mstns:Nazwa"/>
					<br/>
					<xsl:value-of select="mstns:Adresat/mstns:Ulica"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Adresat/mstns:NumerDomu"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="mstns:Adresat/mstns:NumerLokalu"/>
					<br/>
					<xsl:value-of select="mstns:Adresat/mstns:KodPocztowy"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Adresat/mstns:Miejscowosc"/>
				</td>
			</tr>

			<tr>
				<th>Nadawca</th>
				<td>
					<xsl:value-of select="mstns:Nadawca/mstns:Nazwa"/>
					<br/>
					<xsl:value-of select="mstns:Nadawca/mstns:Ulica"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Nadawca/mstns:NumerDomu"/>
					<br/>
					<xsl:value-of select="mstns:Nadawca/mstns:KodPocztowy"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Nadawca/mstns:Miejscowosc"/>
				</td>
			</tr>

			<tr>
				<th>Tryb doręczenia</th>
				<td>
					<xsl:value-of select="mstns:TrybDoreczenia"/>

					<xsl:if test="mstns:TrybDoreczenia/@DoRakWlasnych">
						<xsl:text> (Do rąk własnych: </xsl:text>

						<xsl:choose>
							<xsl:when test="mstns:TrybDoreczenia/@DoRakWlasnych='true'">TAK</xsl:when>
							<xsl:when test="mstns:TrybDoreczenia/@DoRakWlasnych='false'">NIE</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="mstns:TrybDoreczenia/@DoRakWlasnych"/>
							</xsl:otherwise>
						</xsl:choose>

						<xsl:text>)</xsl:text>
					</xsl:if>

				</td>
			</tr>


			<xsl:if test="string-length(normalize-space(mstns:Rodzaj)) &gt; 0">
				<tr>
					<th>Rodzaj</th>
					<td>
						<xsl:value-of select="mstns:Rodzaj"/>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(mstns:Adnotacje)) &gt; 0">
				<tr>
					<th>Adnotacje</th>
					<td>
						<xsl:value-of select="mstns:Adnotacje"/>
					</td>
				</tr>
			</xsl:if>

			<!--<xsl:if test="string-length(normalize-space(mstns:Sygnatura)) &gt; 0">
				<tr>
					<th>Sygnatura</th>
					<td>
						<xsl:value-of select="mstns:Sygnatura"/>
					</td>
				</tr>
			</xsl:if>-->

		</table>

	</xsl:template>


	<!-- PODPIS -->
	<xsl:template match="mstns:PrzesylkaPodpis">

		<h2>Informacje o doręczeniu</h2>

		<table>
			<tr>
				<th>Data zdarzenia</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:DataZdarzenia"/>
					</xsl:call-template>
				</td>
			</tr>

			<tr>
				<th>Rodzaj doręczenia</th>
				<td>
					<xsl:value-of select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora/mstns:RodzajDoreczenie"/>
				</td>
			</tr>

			<tr>
				<th>Podmiot doręczenia</th>
				<td>
					<xsl:value-of select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora/mstns:PodmiotDoreczenia"/>
				</td>
			</tr>

			<xsl:if test="string-length(normalize-space(mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora/mstns:TrescAdnotacji)) &gt; 0">
				<tr>
					<th>Adnotacja</th>
					<td>
						<xsl:value-of select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora/mstns:TrescAdnotacji"/>
					</td>
				</tr>
			</xsl:if>

		</table>

		<div class="signature">
			<strong>Podpis odbiorcy:</strong>

			<xsl:if test="string-length(normalize-space(mstns:PodpisObraz)) &gt; 0">
				<img>
					<xsl:attribute name="src">
						<xsl:text>data:image/png;base64,</xsl:text>
						<xsl:value-of select="mstns:PodpisObraz"/>
					</xsl:attribute>
				</img>
			</xsl:if>

			<xsl:if test="mstns:DaneBiometryczne/mstns:DataPodpisu">
				<div class="sig-date">
					Data podpisu:
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DaneBiometryczne/mstns:DataPodpisu"/>
					</xsl:call-template>
				</div>
			</xsl:if>

		</div>

		<!--<h2>Podpis cyfrowy</h2>
		<table>
			<tr>
				<th>Certyfikat (Subject)</th>
				<td>
					<xsl:value-of select="mstns:PodpisCyfrowy/ds:Signature/ds:KeyInfo/ds:X509Data/ds:X509SubjectName"/>
				</td>
			</tr>
			<tr>
				<th>Signing Time</th>
				<td>
					<xsl:value-of select="mstns:PodpisCyfrowy/ds:Signature/ds:Object//*[local-name()='SigningTime']"/>
				</td>
			</tr>
		</table>-->

	</xsl:template>

</xsl:stylesheet>
