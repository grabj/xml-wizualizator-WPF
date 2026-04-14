<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mstns="KartaEPO/2018/07/15"
	xmlns:mstns2="http://msepo.gov.pl/epo/XSD/KartaEPO.xsd"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    exclude-result-prefixes="mstns ds">

	<xsl:output method="html" indent="yes" encoding="UTF-8"/>

	<!-- Format YYYY-MM-DD HH:MM:SS -->
	<xsl:template name="format-date">
		<xsl:param name="datetime"/>
		<xsl:if test="string-length(normalize-space($datetime)) &gt; 0">
			<xsl:value-of select="substring($datetime,1,10)"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="substring($datetime,12,8)"/>
		</xsl:if>
	</xsl:template>

	<!-- ROOT -->
	<xsl:template match="/">
		<html>
			<head>
				<meta charset="UTF-8"/>
				<title>EPO</title>
				<style>
					body { font-family: Arial, sans-serif; padding: 10px; }
					h1 { color:#1a4d80; }
					h2 { background:#e6f2ff; padding:4px 10px; border-radius:5px; margin-top:25px; }
					table { border-collapse: collapse; width: 100%; margin-bottom: 20px; box-shadow: 0 0 5px #ccc;}
					th, td { border: 1px solid #ccc; padding: 8px; text-align: left; vertical-align: top; }
					th { width: 30%; background:#f5f5f5; }
					.signature { border:1px solid #888; padding:10px; background:#fafafa; display:inline-block; margin-top:5px; }
					.signature img { max-width:400px; display:block; margin-bottom:5px; }
					.sig-date { font-size:12px; color:#555; text-align:center; }
				</style>
			</head>
			<body>

				<h1>Elektroniczne Potwierdzenie Odbioru</h1>

				<!-- Wybór najlepszego szablonu: najpierw KartaEpo, jeśli nie ma -> TabletKartaEpo -->
				<xsl:choose>
					<xsl:when test="mstns:KartaEpo">
						<xsl:apply-templates select="mstns:KartaEpo"/>
					</xsl:when>
					<xsl:when test="mstns2:TabletKartaEpo">
						<xsl:apply-templates select="mstns2:TabletKartaEpo"/>
					</xsl:when>
					<xsl:otherwise>
						<p>
							Wybrano niewłaściwy szablon.
						</p>
					</xsl:otherwise>
				</xsl:choose>

			</body>
		</html>
	</xsl:template>

	<!--  TabletKartaEpo -->
	<xsl:template match="mstns2:TabletKartaEpo">

		<h2>Dane ogólne</h2>
		<table>
			<tr>
				<th>Data utworzenia EPO</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns2:CreationDate"/>
					</xsl:call-template>
				</td>
			</tr>

		</table>

		<xsl:apply-templates select="mstns2:TabletPrzesylki/mstns2:TabletPrzesylkaPodpis/mstns2:TabletPrzesylka"/>
	</xsl:template>

	<xsl:template match="mstns2:TabletPrzesylka">
		<table>

			<xsl:if test="string-length(normalize-space(*[local-name()='IDPrzesylka'])) &gt; 0">
				<tr>
					<th>Id przesyłki</th>
					<td>
						<xsl:value-of select="*[local-name()='IDPrzesylka']"/>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(*[local-name()='NumerNadania'])) &gt; 0">
				<tr>
					<th>Numer nadania</th>
					<td>
						<xsl:value-of select="*[local-name()='NumerNadania']"/>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(*[local-name()='DataNadania'])) &gt; 0">
				<tr>
					<th>Data nadania</th>
					<td>
						<xsl:call-template name="format-date">
							<xsl:with-param name="datetime" select="*[local-name()='DataNadania']"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(*[local-name()='DataPisma'])) &gt; 0">
				<tr>
					<th>Data pisma</th>
					<td>
						<xsl:call-template name="format-date">
							<xsl:with-param name="datetime" select="mstns2:DataPisma"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(mstns2:Rodzaj)) &gt; 0">

				<tr>
					<th>Rodzaj przesyłki</th>
					<td>
						<xsl:value-of select="mstns2:Rodzaj"/>
					</td>
				</tr>
			</xsl:if>

			<tr>
				<th>Adresat</th>
				<td>
					<xsl:value-of select="mstns2:Adresat"/>
					<br/>
					<xsl:value-of select="mstns2:Ulica"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns2:Dom"/>
					<xsl:if test="string-length(normalize-space(mstns2:Lokal)) &gt; 0">
						<xsl:text> / </xsl:text>
						<xsl:value-of select="mstns2:Lokal"/>
					</xsl:if>
					<br/>
					<xsl:value-of select="mstns2:KodPocztowy"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns2:Miejscowosc"/>
				</td>
			</tr>

			<tr>
				<th>Nadawca</th>
				<td>
					<xsl:value-of select="mstns2:TabletJednostkaMS/mstns2:NazwaJednostki"/>
					<br/>
					<xsl:value-of select="mstns2:TabletJednostkaMS/mstns2:Ulica"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns2:TabletJednostkaMS/mstns2:Dom"/>
					<xsl:if test="string-length(normalize-space(mstns2:TabletJednostkaMS/mstns2:Lokal)) &gt; 0">
						<xsl:text> / </xsl:text>
						<xsl:value-of select="mstns2:TabletJednostkaMS/mstns2:Lokal"/>
					</xsl:if>
					<br/>
					<xsl:value-of select="mstns2:TabletJednostkaMS/mstns2:KodPocztowy"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns2:TabletJednostkaMS/mstns2:Miasto"/>
				</td>
			</tr>

		</table>

		<h2>Informacje o odbiorze</h2>

		<table>
			<tr>
				<th>Status</th>
				<td>
					<xsl:choose>
						<xsl:when test="mstns2:StatusPrzesylki=2">Doręczona</xsl:when>
						<xsl:when test="mstns2:StatusPrzesylki=4">Brak doręczenia</xsl:when>
						<xsl:when test="mstns2:StatusPrzesylki=5">Wydana (po awizo)</xsl:when>
						<xsl:when test="mstns2:StatusPrzesylki=6">Zwrot (po awizo)</xsl:when>
						<xsl:otherwise>Nieznany</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>

			<!-- ODBIORCA (tylko dla 2 i 5) -->
			<xsl:if test="mstns2:StatusPrzesylki=2 or mstns2:StatusPrzesylki=5">
				<tr>
					<th>Odbiorca</th>
					<td>
						<xsl:choose>

							<!-- STATUS 2 -->
							<xsl:when test="mstns2:StatusPrzesylki=2">
								<xsl:choose>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=0">Adresat</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=1">Dorosły domownik</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=2">Dozorca</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=3">Sołtys</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=4">Administracja domu</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=5">Upoważniony pracownik</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=6">Przełożony żołnierza</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=7">Przełożony funkcjonariusza Policji</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=8">Przełożony funkcjonariusza Agencji Bezpieczeństwa Wewnętrznego</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=9">Przełożony funkcjonariusza Agencji Wywiadu</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=10">Przełożony funkcjonariusza Służby Kontrwywiadu Wojskowego</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=11">Przełożony funkcjonariusza Służby Wywiadu Wojskowego</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=12">Przełożony funkcjonariusza Straży Granicznej</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=13">Przełożony funkcjonariusza Służby Celnej</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=14">Przełożony funkcjonariusza Centralnego Biura Antykorupcyjnego</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=15">Przełożony funkcjonariusza Służby Więziennej</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=16">Przedstawiciel ustawowy adresata</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=20">Adresat, który nie mógł lub odmówił pokwitowania odbioru przesyłki</xsl:when>
								</xsl:choose>
							</xsl:when>

							<!-- STATUS 5 -->
							<xsl:when test="mstns2:StatusPrzesylki=5">
								<xsl:choose>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=0">Adresat</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=1">Upoważniony pracownik</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=2">Osoba uprawniona do reprezentacji</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=3">Pełnomocnik pocztowy</xsl:when>
									<xsl:when test="mstns2:OdbiorcaPrzesylki=4">Przedstawiciel ustawowy adresata</xsl:when>
								</xsl:choose>
							</xsl:when>

						</xsl:choose>
					</td>
				</tr>
			</xsl:if>

			<!-- IMIĘ I NAZWISKO (tylko gdy faktycznie było doręczenie lub wydanie) -->
			<xsl:if test="mstns2:StatusPrzesylki=2 or mstns2:StatusPrzesylki=5">
				<tr>
					<th>Imię i nazwisko odbiorcy</th>
					<td>
						<xsl:value-of select="mstns2:ImieINazwiskoOdbiorcy"/>
					</td>
				</tr>
			</xsl:if>

			<!-- BRAK DORĘCZENIA (4 i 6) -->
			<xsl:if test="mstns2:StatusPrzesylki=4 or mstns2:StatusPrzesylki=6">
				<tr>
					<th>Powód braku doręczenia</th>
					<td>
						<xsl:choose>
							<xsl:when test="mstns2:BrakDoreczenia=0">Adresat odmówił przyjęcia</xsl:when>
							<xsl:when test="mstns2:BrakDoreczenia=1">Niepełny adres</xsl:when>
							<xsl:when test="mstns2:BrakDoreczenia=2">
								Nie doręczono z innych przyczyn
								<xsl:value-of select="mstns2:BrakDoreczeniaInnaPrzyczyna"/>
							</xsl:when>
							<xsl:when test="mstns2:BrakDoreczenia=3">
								Nie podjęto przesyłki z placówki pocztowej/Urzędu Gminy
							</xsl:when>
						</xsl:choose>
					</td>
				</tr>
			</xsl:if>

			<tr>
				<th>Data odbioru</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns2:SystemowaDataOznaczenia"/>
					</xsl:call-template>
				</td>
			</tr>

			<!-- AWIZO – tylko jeśli pola istnieją -->

			<xsl:if test="string-length(normalize-space(mstns2:DataAwizo1)) &gt; 0">
				<tr>
					<th>Data pierwszego awizo</th>
					<td>
						<xsl:call-template name="format-date">
							<xsl:with-param name="datetime" select="mstns2:DataAwizo1"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>

			<xsl:if test="string-length(normalize-space(mstns2:DataAwizo2)) &gt; 0">
				<tr>
					<th>Data drugiego awizo</th>
					<td>
						<xsl:call-template name="format-date">
							<xsl:with-param name="datetime" select="mstns2:DataAwizo2"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>


		</table>

		<div class="signature">
			<strong>Podpis odbiorcy:</strong>

			<xsl:if test="string-length(normalize-space(mstns2:Podpis)) &gt; 0">
				<img>
					<xsl:attribute name="src">
						<xsl:text>data:image/png;base64,</xsl:text>
						<xsl:value-of select="mstns2:Podpis"/>
					</xsl:attribute>
				</img>
			</xsl:if>

			<div class="sig-label">
				<xsl:value-of select="mstns2:ImieINazwiskoOdbiorcy"/>
			</div>

			<xsl:if test="string-length(normalize-space(mstns2:DaneBiometryczne/mstns2:DataPodpisu)) &gt; 0">
				<div class="sig-date">
					Data podpisu:
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns2:DaneBiometryczne/mstns2:DataPodpisu"/>
					</xsl:call-template>
				</div>
			</xsl:if>

		</div>

	</xsl:template>

	<!-- KARTA EPO -->
	<xsl:template match="mstns:KartaEpo">

		<h2>Dane ogólne</h2>
		<table>
			<tr>
				<th>Data utworzenia EPO</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataUtworzenia"/>
					</xsl:call-template>
				</td>
			</tr>
			<tr>
				<th>Id karty EPO</th>
				<td>
					<xsl:value-of select="mstns:IdKartyEPO"/>
				</td>
			</tr>
		</table>

		<xsl:apply-templates select="mstns:Przesylka"/>
		<xsl:apply-templates select="mstns:PrzesylkaPodpis"/>

	</xsl:template>

	<!-- PRZESYŁKA -->
	<xsl:template match="mstns:Przesylka">

		<h2>Dane przesyłki</h2>

		<table>

			<tr>
				<th>Id przesyłki</th>
				<td>
					<xsl:value-of select="mstns:IdPrzesylki"/>
				</td>
			</tr>

			<tr>
				<th>Numer nadania</th>
				<td>
					<xsl:value-of select="mstns:NumerNadania"/>
				</td>
			</tr>

			<tr>
				<th>Data nadania</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataNadania"/>
					</xsl:call-template>
				</td>
			</tr>

			<tr>
				<th>Data pisma</th>
				<td>
					<xsl:call-template name="format-date">
						<xsl:with-param name="datetime" select="mstns:DataPisma"/>
					</xsl:call-template>
				</td>
			</tr>

			<tr>
				<th>Adresat</th>
				<td>
					<xsl:value-of select="mstns:Adresat/mstns:Nazwa"/>
					<br/>
					<xsl:value-of select="mstns:Adresat/mstns:Ulica"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mstns:Adresat/mstns:NumerDomu"/>
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

		</table>

	</xsl:template>

	<!-- PODPIS / ZWROT -->
	<xsl:template match="mstns:PrzesylkaPodpis">

		<xsl:variable name="adnotacja"
            select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora"/>

		<xsl:choose>

			<!-- ZWROT -->
			<xsl:when test="string-length(normalize-space($adnotacja/mstns:RodzajZwrot)) &gt; 0">

				<h2>Informacje o zwrocie</h2>

				<table>

					<tr>
						<th>Powód zwrotu</th>
						<td>
							<xsl:value-of select="$adnotacja/mstns:PowodZwrotu"/>
						</td>
					</tr>

					<tr>
						<th>Data zwrotu</th>
						<td>
							<xsl:call-template name="format-date">
								<xsl:with-param name="datetime"
                                    select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:DataZdarzenia"/>
							</xsl:call-template>
						</td>
					</tr>
				</table>

			</xsl:when>

			<!-- DORĘCZENIE -->
			<xsl:otherwise>

				<h2>Informacje o doręczeniu</h2>

				<table>
					<tr>
						<th>Rodzaj doręczenia</th>
						<td>
							<xsl:value-of select="$adnotacja/mstns:RodzajDoreczenie"/>
						</td>
					</tr>

					<tr>
						<th>Podmiot doręczenia</th>
						<td>
							<xsl:value-of select="$adnotacja/mstns:PodmiotDoreczenia"/>
						</td>
					</tr>
					
			<xsl:if test="string-length(normalize-space(mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora/mstns:TrescAdnotacji)) &gt; 0">
				<tr>
					<th>Odbiorca</th>
					<td>
						<xsl:value-of select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:AdnotacjaOperatora/mstns:TrescAdnotacji"/>
					</td>
				</tr>
			</xsl:if>

					<tr>
						<th>Data doręczenia</th>
						<td>
							<xsl:call-template name="format-date">
								<xsl:with-param name="datetime"
                                    select="mstns:AdnotacjaKoncowa/mstns:PrzesylkaAdnotacja/mstns:DataZdarzenia"/>
							</xsl:call-template>
						</td>
					</tr>
				</table>

				<xsl:if test="string-length(normalize-space(mstns:PodpisObraz)) &gt; 0">
					<div class="signature">
						<strong>Podpis odbiorcy:</strong>

						<img>
							<xsl:attribute name="src">
								<xsl:text>data:image/png;base64,</xsl:text>
								<xsl:value-of select="mstns:PodpisObraz"/>
							</xsl:attribute>
						</img>
					</div>
				</xsl:if>

			</xsl:otherwise>

		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>