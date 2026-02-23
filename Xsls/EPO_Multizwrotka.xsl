<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ke="KartaEPO/2018/07/15"
    exclude-result-prefixes="ke">

    <xsl:output method="html" indent="yes" encoding="UTF-8"/>

    <!-- ===================================================== -->
    <!-- ROOT -->
    <!-- ===================================================== -->

    <xsl:template match="/">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>KartaEPO - Multizwrotka Doręczenie</title>
                <style>
                    body{font-family:Arial;font-size:12px}
                    table{border-collapse:collapse;width:100%;margin-bottom:15px}
                    th,td{border:1px solid #ccc;padding:4px;text-align:left}
                    h2{background:#eee;padding:5px}
                </style>
            </head>
            <body>

                <h1>Karta EPO – Multizwrotka Doręczenie</h1>

                <b>Data utworzenia:</b>
                <xsl:value-of select="ke:DataUtworzenia"/>
                <br/>
                <b>ID Karty:</b>
                <xsl:value-of select="ke:IdKartyEPO"/>

                <xsl:apply-templates select="ke:Przesylka"/>
                <xsl:apply-templates select="ke:PrzesylkaPodpis"/>

            </body>
        </html>
    </xsl:template>

    <!-- ===================================================== -->
    <!-- PRZESYŁKA -->
    <!-- ===================================================== -->

    <xsl:template match="ke:Przesylka">
        <h2>Dane przesyłki</h2>
        <table>
            <tr>
                <th>ID</th>
                <td>
                    <xsl:value-of select="ke:IdPrzesylki"/>
                </td>
            </tr>
            <tr>
                <th>Numer nadania</th>
                <td>
                    <xsl:value-of select="ke:NumerNadania"/>
                </td>
            </tr>
            <tr>
                <th>Data nadania</th>
                <td>
                    <xsl:value-of select="ke:DataNadania"/>
                </td>
            </tr>
            <tr>
                <th>Data pisma</th>
                <td>
                    <xsl:value-of select="ke:DataPisma"/>
                </td>
            </tr>
            <tr>
                <th>Tryb doręczenia</th>
                <td>
                    <xsl:value-of select="ke:TrybDoreczenia"/>
                    <xsl:if test="ke:TrybDoreczenia/@DoRakWlasnych='true'">
                        (Do rąk własnych)
                    </xsl:if>
                </td>
            </tr>
            <tr>
                <th>Sygnatura</th>
                <td>
                    <xsl:value-of select="ke:Sygnatura"/>
                </td>
            </tr>
            <tr>
                <th>Rodzaj</th>
                <td>
                    <xsl:value-of select="ke:Rodzaj"/>
                </td>
            </tr>
        </table>

        <h3>Adnotacje</h3>
        <xsl:apply-templates select="ke:Adnotacje/ke:PrzesylkaAdnotacja"/>
    </xsl:template>

    <!-- ===================================================== -->
    <!-- ADNOTACJA -->
    <!-- ===================================================== -->

    <xsl:template match="ke:PrzesylkaAdnotacja">
        <table>
            <tr>
                <th>Data adnotacji</th>
                <td>
                    <xsl:value-of select="ke:DataAdnotacji"/>
                </td>
            </tr>
            <tr>
                <th>Data zdarzenia</th>
                <td>
                    <xsl:value-of select="ke:DataZdarzenia"/>
                </td>
            </tr>
            <tr>
                <th>Operator</th>
                <td>
                    <xsl:value-of select="ke:Operator/ke:Imie"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="ke:Operator/ke:Nazwisko"/>
                </td>
            </tr>

            <tr>
                <th>Typ zdarzenia</th>
                <td>
                    <xsl:call-template name="RodzajAdnotacji"/>
                </td>
            </tr>

            <tr>
                <th>Szczegóły</th>
                <td>
                    <xsl:call-template name="SzczegolyAdnotacji"/>
                </td>
            </tr>

        </table>
    </xsl:template>

    <!-- ===================================================== -->
    <!-- RODZAJ ADNOTACJI -->
    <!-- ===================================================== -->

    <xsl:template name="RodzajAdnotacji">
        <xsl:choose>
            <xsl:when test="ke:AdnotacjaOperatora/ke:RodzajAwizoPierwsze">Pierwsze awizo</xsl:when>
            <xsl:when test="ke:AdnotacjaOperatora/ke:RodzajAwizoDrugie">Drugie awizo</xsl:when>
            <xsl:when test="ke:AdnotacjaOperatora/ke:RodzajDoreczenie">Doręczenie</xsl:when>
            <xsl:when test="ke:AdnotacjaOperatora/ke:RodzajZwrot">Zwrot</xsl:when>
            <xsl:when test="ke:AdnotacjaOperatora/ke:RodzajWydanie">Wydanie</xsl:when>
            <xsl:when test="ke:AdnotacjaOperatora/ke:RodzajZwrotNiepodjetej">Zwrot niepodjętej</xsl:when>
            <xsl:when test="ke:AdnotacjaOperatora/ke:RodzajPrzyjecieNiedoreczonej">Przyjęcie niedoręczonej</xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- ===================================================== -->
    <!-- SZCZEGÓŁY ADNOTACJI -->
    <!-- ===================================================== -->

    <xsl:template name="SzczegolyAdnotacji">
        <xsl:choose>

            <!-- DORĘCZENIE -->
            <xsl:when test="ke:AdnotacjaOperatora/ke:PodmiotDoreczenia">
                Podmiot doręczenia:
                <xsl:call-template name="PodmiotDoreczenia">
                    <xsl:with-param name="kod" select="ke:AdnotacjaOperatora/ke:PodmiotDoreczenia"/>
                </xsl:call-template>
            </xsl:when>

            <!-- WYDANIE -->
            <xsl:when test="ke:AdnotacjaOperatora/ke:PodmiotWydania">
                Podmiot wydania:
                <xsl:call-template name="PodmiotWydania">
                    <xsl:with-param name="kod" select="ke:AdnotacjaOperatora/ke:PodmiotWydania"/>
                </xsl:call-template>
            </xsl:when>

            <!-- ZWROT -->
            <xsl:when test="ke:AdnotacjaOperatora/ke:PowodZwrotu">
                Powód zwrotu:
                <xsl:call-template name="PowodZwrotu">
                    <xsl:with-param name="kod" select="ke:AdnotacjaOperatora/ke:PowodZwrotu"/>
                </xsl:call-template>
            </xsl:when>

            <!-- AWIZO -->
            <xsl:when test="ke:AdnotacjaOperatora/ke:AwizoMiejscePozostawieniaPrzesylki">
                Miejsce pozostawienia przesyłki:
                <xsl:call-template name="MiejscePrzesylki">
                    <xsl:with-param name="kod" select="ke:AdnotacjaOperatora/ke:AwizoMiejscePozostawieniaPrzesylki"/>
                </xsl:call-template>
                <br/>
                Miejsce pozostawienia zawiadomienia:
                <xsl:call-template name="MiejsceZawiadomienia">
                    <xsl:with-param name="kod" select="ke:AdnotacjaOperatora/ke:AwizoMiejscePozostawieniaAwizo"/>
                </xsl:call-template>
            </xsl:when>

        </xsl:choose>

        <xsl:if test="ke:AdnotacjaOperatora/ke:TrescAdnotacji">
            <br/>Treść: <xsl:value-of select="ke:AdnotacjaOperatora/ke:TrescAdnotacji"/>
        </xsl:if>

    </xsl:template>

    <!-- ===================================================== -->
    <!-- SŁOWNIKI -->
    <!-- ===================================================== -->

    <!-- PODMIOT DORĘCZENIA -->
    <xsl:template name="PodmiotDoreczenia">
        <xsl:param name="kod"/>
        <xsl:call-template name="PodmiotMapa"/>
    </xsl:template>

    <!-- PODMIOT WYDANIA -->
    <xsl:template name="PodmiotWydania">
        <xsl:param name="kod"/>
        <xsl:call-template name="PodmiotMapa"/>
    </xsl:template>

    <!-- WSPÓLNA MAPA PODMIOTÓW -->
    <xsl:template name="PodmiotMapa">
        <xsl:param name="kod"/>

        <xsl:choose>
            <xsl:when test="$kod='ADRESAT'">Adresat</xsl:when>
            <xsl:when test="$kod='DOROSLY_DOMOWNIK'">Dorosły domownik</xsl:when>
            <xsl:when test="$kod='PELNOLETNI_DOMOWNIK'">Pełnoletni domownik</xsl:when>
            <xsl:when test="$kod='SASIAD'">Sąsiad</xsl:when>
            <xsl:when test="$kod='DOZORCA_DOMU'">Dozorca</xsl:when>
            <xsl:when test="$kod='SOLTYS'">Sołtys</xsl:when>
            <xsl:when test="$kod='ADMINISTRACJA_DOMU'">Administracja domu</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_ZOLNIERZA'">Przełożony żołnierza</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_POLICJI'">Przełożony Policji</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_ABW'">Przełożony ABW</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_AW'">Przełożony AW</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_SKW'">Przełożony SKW</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_SWW'">Przełożony SWW</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_SG'">Przełożony SG</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_SC'">Przełożony SC</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_CBA'">Przełożony CBA</xsl:when>
            <xsl:when test="$kod='PRZELOZONY_SW'">Przełożony SW</xsl:when>
            <xsl:when test="$kod='PRZEDSTAWICIEL_USTAWOWY'">Przedstawiciel ustawowy</xsl:when>
            <xsl:when test="$kod='ADRESAT_KTORY_NIE_MOGL'">Adresat nie mógł/odmówił</xsl:when>
            <xsl:when test="$kod='UPOWAZNIONY_PRACOWNIK'">Upoważniony pracownik</xsl:when>
            <xsl:when test="$kod='PELNOMOCNIK_POCZTOWY'">Pełnomocnik pocztowy</xsl:when>
            <xsl:when test="$kod='PELNOMOCNIK_ADRESATA'">Pełnomocnik adresata</xsl:when>
            <xsl:when test="$kod='OSOBA_UPRAWNIONA_DO_REPREZENTACJI'">Osoba uprawniona do reprezentacji</xsl:when>
            <xsl:when test="$kod='SKRZYNKA_ODDAWCZA'">Skrzynka oddawcza</xsl:when>
            <xsl:when test="$kod='OSOBA_UPRAWNIONA_DO_ODBIORU'">Osoba upoważniona</xsl:when>
            <xsl:when test="$kod='OSOBA_UPOWAZNIONA_DO_ODB_KORESP'">Osoba upoważniona do odbioru korespondencji</xsl:when>
            <xsl:when test="$kod='KIEROWNIK_JEDNOSTKI_LUB_UPOWAZNIONY'">Kierownik jednostki lub osoba upoważniona</xsl:when>
            <xsl:when test="$kod='PRZEDSTAWICIEL_ADRESATA'">Przedstawiciel adresata</xsl:when>
            <xsl:when test="$kod='OSOBA_UPOWAZNIONA_DO_REPREZENT_ADRESATA'">Osoba upoważniona do reprezentowania adresata</xsl:when>
            <xsl:when test="$kod='OSOBA_UPOWAZNIONA_PRZEZ_PRACODAWCE'">Osoba upoważniona przez pracodawcę</xsl:when>
            <xsl:when test="$kod='SKRYTKA_POCZTOWA'">Skrytka pocztowa</xsl:when>
            <xsl:when test="$kod='PROKURENT'">Prokurent</xsl:when>
            <xsl:when test="$kod='ZARZADCA_DOMU'">Zarządca domu</xsl:when>
            <xsl:when test="$kod='OSOBA_UPOWAZNIONA_PRZEZ_KIER_WIEZIENIA'">Osoba upoważniona przez kierownika zakładu karnego</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$kod"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- POWÓD ZWROTU -->
    <xsl:template name="PowodZwrotu">
        <xsl:param name="kod"/>
        <xsl:choose>
            <xsl:when test="$kod='ODMOWA'">Adresat odmówił przyjęcia</xsl:when>
            <xsl:when test="$kod='ADRESAT_ZMARL'">Adresat zmarł</xsl:when>
            <xsl:when test="$kod='ADRESAT_NIEZNANY'">Adresat nieznany</xsl:when>
            <xsl:when test="$kod='ADRESAT_WYPROWADZIL_SIE'">Adresat wyprowadził się</xsl:when>
            <xsl:when test="$kod='INNA'">Niedoręczona z innych przyczyn</xsl:when>
            <xsl:when test="$kod='ADRES_NIEPELNY'">Niekompletny adres</xsl:when>
            <xsl:when test="$kod='ADRES_BLEDNY'">Błędny adres</xsl:when>
            <xsl:when test="$kod='ADRES_NIEZGODNY'">Niezgodność adresów</xsl:when>
            <xsl:when test="$kod='ADRES_NIEZNALEZIONY'">Adres nie do znalezienia</xsl:when>
            <xsl:when test="$kod='ADRESAT_NIE_ZASTANO'">Nie zastano adresata</xsl:when>
            <xsl:when test="$kod='ADRESAT_NIE_ZGLASZA_SIE'">Adresat nie zgłasza się</xsl:when>
            <xsl:when test="$kod='ADRESAT_NIEOBECNY'">Adresat nieobecny</xsl:when>
            <xsl:when test="$kod='ADRESAT_NIEODNALEZIONY'">Nie można odnaleźć adresata</xsl:when>
            <xsl:when test="$kod='ADRESAT_STRAJKUJE'">Adresat strajkuje</xsl:when>
            <xsl:when test="$kod='DO_NADAWCY_NA_POZNIEJ'">Nadawca żąda późniejszego dostarczenia</xsl:when>
            <xsl:when test="$kod='MYLNE_SKIEROWANIE'">Przesyłka niewłaściwie skierowana</xsl:when>
            <xsl:when test="$kod='NADAWCA_ODMOWIL'">Nadawca odmówił przyjęcia</xsl:when>
            <xsl:when test="$kod='NIE_PODJETO'">Nie podjęto przesyłki</xsl:when>
            <xsl:when test="$kod='NIEZGODNE_WYMAGANIA'">Niezgodna z wymaganiami klienta</xsl:when>
            <xsl:when test="$kod='POBRANIE_NIEZGODNE'">Niezgodność kwoty pobrania</xsl:when>
            <xsl:when test="$kod='USZKODZONA'">Uszkodzona</xsl:when>
            <xsl:when test="$kod='ZAMKNIETA_SIEDZIBA'">Zamknięta siedziba</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$kod"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- MIEJSCA AWIZO -->
    <xsl:template name="MiejscePrzesylki">
        <xsl:param name="kod"/>
        <xsl:choose>
            <xsl:when test="$kod='POZOSTAWIONA_W_URZEDZIE'">Placówka pocztowa</xsl:when>
            <xsl:when test="$kod='POZOSTAWIONA_W_GMINIE'">Urząd gminy</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$kod"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="MiejsceZawiadomienia">
        <xsl:param name="kod"/>
        <xsl:choose>
            <xsl:when test="$kod='SKRZYNKA_ODDAWCZA'">Skrzynka oddawcza</xsl:when>
            <xsl:when test="$kod='DRZWI_MIESZKANIA'">Drzwi</xsl:when>
            <xsl:when test="$kod='SKRYTKA_POCZTOWA'">Skrytka pocztowa</xsl:when>
            <xsl:when test="$kod='INNE_WIDOCZNE_MIEJSCE'">Inne widoczne miejsce</xsl:when>
            <xsl:when test="$kod='BIURO'">Biuro</xsl:when>
            <xsl:when test="$kod='DRZWI_INNEGO_POMIESZCZENIA'">Inne pomieszczenie</xsl:when>
            <xsl:when test="$kod='PRZY_WEJSCIU_NA_POSESJE'">Widoczne miejsce przy wejściu</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$kod"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- PODPIS GRAFICZNY -->
    <xsl:template match="ke:PrzesylkaPodpis">
        <h2>Podpis</h2>

        <p>
            <b>Systemowa data oznaczenia:</b>
            <xsl:value-of select="ke:SystemowaDataOznaczenia"/>
        </p>

        <xsl:if test="ke:PodpisObraz">
            <h3>Obraz podpisu</h3>
            <img>
                <xsl:attribute name="src">
                    <xsl:text>data:image/png;base64,</xsl:text>
                    <xsl:value-of select="ke:PodpisObraz"/>
                </xsl:attribute>
            </img>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>