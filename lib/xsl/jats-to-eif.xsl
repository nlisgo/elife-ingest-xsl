<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text" encoding="utf-8"/>

    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
    <xsl:variable name="status">
        <xsl:choose>
            <xsl:when test="//pub-date[@pub-type='collection']/year">
                <xsl:value-of select="'VOR'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'POA'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:text>{&#10;</xsl:text>
        <xsl:call-template name="item">
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="key">article-type</xsl:with-param>
            <xsl:with-param name="value" select="article/@article-type"/>
        </xsl:call-template>
        <xsl:apply-templates select="article/front/article-meta"/>
        <xsl:call-template name="collection">
            <xsl:with-param name="key">fragments</xsl:with-param>
            <xsl:with-param name="value_prefix" select="'['"/>
            <xsl:with-param name="value"><xsl:call-template name="fragments"/></xsl:with-param>
            <xsl:with-param name="value_suffix" select="']'"/>
        </xsl:call-template>
        <xsl:call-template name="collection">
            <xsl:with-param name="key">citations</xsl:with-param>
            <xsl:with-param name="value"><xsl:apply-templates select="//ref-list/ref/element-citation | //ref-list/ref/mixed-citation"/></xsl:with-param>
        </xsl:call-template>
        <xsl:text>&#10;}</xsl:text>
    </xsl:template>

    <xsl:template match="article-meta">
        <xsl:call-template name="item">
            <xsl:with-param name="key">title</xsl:with-param>
            <xsl:with-param name="value">
                <xsl:apply-templates select="title-group/article-title" mode="formatting"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">status</xsl:with-param>
            <xsl:with-param name="value" select="$status"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">publish</xsl:with-param>
            <xsl:with-param name="value" select="'1'"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">doi</xsl:with-param>
            <xsl:with-param name="value" select="article-id[@pub-id-type='doi']"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">pub-date</xsl:with-param>
            <xsl:with-param name="value"><xsl:call-template name="pub_date"/></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">volume</xsl:with-param>
            <xsl:with-param name="value"><xsl:call-template name="volume"/></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">elocation-id</xsl:with-param>
            <xsl:with-param name="value" select="elocation-id"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">path</xsl:with-param>
            <xsl:with-param name="value"><xsl:call-template name="base_path"/></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">article-id</xsl:with-param>
            <xsl:with-param name="value" select="translate(elocation-id, 'e', '')"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="key">impact-statement</xsl:with-param>
            <xsl:with-param name="value">
                <xsl:apply-templates select="custom-meta-group/custom-meta[@specific-use='meta-only']/meta-name[text()='Author impact statement']/following-sibling::meta-value" mode="formatting"/>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="collection">
            <xsl:with-param name="key">keywords</xsl:with-param>
            <xsl:with-param name="value"><xsl:apply-templates select="kwd-group[@kwd-group-type]"/></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="collection">
            <xsl:with-param name="key">categories</xsl:with-param>
            <xsl:with-param name="value"><xsl:call-template name="subj-groups"/></xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="collection">
            <xsl:with-param name="key">contributors</xsl:with-param>
            <xsl:with-param name="value"><xsl:apply-templates select="contrib-group/contrib"/></xsl:with-param>
            <xsl:with-param name="value_prefix" select="'['"/>
            <xsl:with-param name="value_suffix" select="']'"/>
        </xsl:call-template>
        <xsl:call-template name="contrib-referenced"/>
        <xsl:call-template name="collection">
            <xsl:with-param name="key">related-articles</xsl:with-param>
            <xsl:with-param name="value"><xsl:apply-templates select="related-article"/></xsl:with-param>
            <xsl:with-param name="value_prefix" select="'['"/>
            <xsl:with-param name="value_suffix" select="']'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="item">
        <xsl:param name="prefix" select="',&#10;'"/>
        <xsl:param name="key"/>
        <xsl:param name="value" select="''"/>
        <xsl:param name="default_value" select="''"/>
        <xsl:if test="normalize-space($value) != '' or $default_value != ''">
            <xsl:value-of select="$prefix"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$key"/>
            <xsl:text>": </xsl:text>
            <xsl:choose>
                <xsl:when test="normalize-space($value) != ''">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$value"/>
                    <xsl:text>"</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default_value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="collection">
        <xsl:param name="force" select="0"/>
        <xsl:param name="prefix" select="',&#10;'"/>
        <xsl:param name="key" select="''"/>
        <xsl:param name="value"/>
        <xsl:param name="value_prefix" select="'{'"/>
        <xsl:param name="value_suffix" select="'}'"/>
        <xsl:if test="$value != '' or $force != 0">
            <xsl:if test="$prefix != ''">
                <xsl:value-of select="$prefix"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$key != ''">
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="$key"/>
                    <xsl:text>": </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$value_prefix"/>
            <xsl:if test="$value != ''">
                <xsl:value-of select="'&#10;'"/>
                <xsl:value-of select="$value"/>
                <xsl:value-of select="'&#10;'"/>
            </xsl:if>
            <xsl:value-of select="$value_suffix"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="kwd-group">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="@kwd-group-type"/>
        <xsl:text>": [</xsl:text>
        <xsl:apply-templates select="kwd"/>
        <xsl:value-of select="'&#10;'"/>
        <xsl:text>]</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:value-of select="',&#10;'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="kwd | subject">
        <xsl:value-of select="'&#10;'"/>
        <xsl:text>"</xsl:text>
        <xsl:apply-templates select="." mode="formatting"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:value-of select="','"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="subj-groups">
        <xsl:if test="//article-categories/subj-group[@subj-group-type='display-channel']/subject">
            <xsl:text>"display-channel": [</xsl:text>
            <xsl:apply-templates select="//article-categories/subj-group[@subj-group-type='display-channel']/subject"/>
            <xsl:value-of select="'&#10;'"/>
            <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:if test="//article-categories/subj-group[@subj-group-type='heading']/subject">
            <xsl:if test="//article-categories/subj-group[@subj-group-type='display-channel']/subject">
                <xsl:text>,&#10;</xsl:text>
            </xsl:if>
            <xsl:text>"heading": [</xsl:text>
                <xsl:apply-templates select="//article-categories/subj-group[@subj-group-type='heading']/subject"/>
            <xsl:value-of select="'&#10;'"/>
            <xsl:text>]</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="pub-date | date">
        <xsl:value-of select="concat(year, '-', month, '-', day)"/>
    </xsl:template>

    <xsl:template name="pub_date">
        <xsl:variable name="date_location">
            <xsl:choose>
                <xsl:when test="//article-meta/pub-date[@date-type='pub']">
                    <xsl:apply-templates select="//article-meta/pub-date[@date-type='pub']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="//article-meta/history/date[@date-type='accepted']"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$date_location"/>
    </xsl:template>

    <xsl:template name="year">
        <xsl:choose>
            <xsl:when test="//article-meta/pub-date[@date-type='pub']/year">
                <xsl:value-of select="//article-meta/pub-date[@date-type='pub']/year"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="//article-meta/permissions/copyright-year"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="related-article">
        <xsl:call-template name="collection">
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="value">
                <xsl:call-template name="item">
                    <xsl:with-param name="key">type</xsl:with-param>
                    <xsl:with-param name="value" select="@related-article-type"/>
                    <xsl:with-param name="prefix" select="''"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">href</xsl:with-param>
                    <xsl:with-param name="value" select="@*[name()='xlink:href']"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="position() != last()">
            <xsl:value-of select="',&#10;'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="element-citation | mixed-citation">
        <xsl:variable name="includes">
            <xsl:if test="person-group[@person-group-type]">
                <xsl:value-of select="'authors|'"/>
            </xsl:if>
            <xsl:if test="year">
                <xsl:value-of select="'year|'"/>
            </xsl:if>
            <xsl:if test="article-title">
                <xsl:value-of select="'title|'"/>
            </xsl:if>
            <xsl:if test="source">
                <xsl:value-of select="'source|'"/>
            </xsl:if>
            <xsl:if test="comment[1]">
                <xsl:value-of select="'comment|'"/>
            </xsl:if>
            <xsl:if test="pub-id[@pub-id-type='doi']">
                <xsl:value-of select="'doi|'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:call-template name="collection">
            <xsl:with-param name="key" select="../@id"/>
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="value">
                <xsl:call-template name="collection">
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'authors|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="key">authors</xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value">
                        <xsl:choose>
                            <xsl:when test="person-group[@person-group-type]/name | person-group[@person-group-type]/collab">
                                <xsl:apply-templates select="person-group[@person-group-type]/name | person-group[@person-group-type]/collab"/>
                            </xsl:when>
                            <xsl:when test="person-group[@person-group-type]">
                                <xsl:call-template name="collection">
                                    <xsl:with-param name="prefix" select="''"/>
                                    <xsl:with-param name="value">
                                        <xsl:call-template name="item">
                                            <xsl:with-param name="prefix" select="''"/>
                                            <xsl:with-param name="key">group-type</xsl:with-param>
                                            <xsl:with-param name="value" select="person-group/@person-group-type"/>
                                        </xsl:call-template>
                                        <xsl:call-template name="item">
                                            <xsl:with-param name="prefix">
                                                <xsl:choose>
                                                    <xsl:when test="not(person-group[@person-group-type])">
                                                        <xsl:value-of select="''"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:text>,&#10;</xsl:text>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:with-param>
                                            <xsl:with-param name="key">collab</xsl:with-param>
                                            <xsl:with-param name="value" select="person-group"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'year|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="key">year</xsl:with-param>
                    <xsl:with-param name="value" select="translate(translate(year, $uppercase, ''), $smallcase, '')"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'title|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="key">title</xsl:with-param>
                    <xsl:with-param name="value"><xsl:apply-templates select="article-title" mode="formatting"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'source|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="key">source</xsl:with-param>
                    <xsl:with-param name="value" select="source"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'comment|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="key">comment</xsl:with-param>
                    <xsl:with-param name="value" select="comment[1]"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'doi|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="key">doi</xsl:with-param>
                    <xsl:with-param name="value" select="pub-id[@pub-id-type='doi']"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="position() != last()">
            <xsl:value-of select="',&#10;'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="person-group[@person-group-type]/name | person-group[@person-group-type]/collab">
        <xsl:variable name="includes">
            <xsl:if test="../@person-group-type">
                <xsl:value-of select="'group-type|'"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="name() = 'collab'">
                    <xsl:value-of select="'collab|'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="surname">
                        <xsl:value-of select="'surname|'"/>
                    </xsl:if>
                    <xsl:if test="given-names">
                        <xsl:value-of select="'given-names|'"/>
                    </xsl:if>
                    <xsl:if test="suffix">
                        <xsl:value-of select="'suffix|'"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="collection">
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="value">
                <xsl:call-template name="item">
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'group-type|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="key">group-type</xsl:with-param>
                    <xsl:with-param name="value" select="../@person-group-type"/>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="name() = 'collab'">
                        <xsl:call-template name="item">
                            <xsl:with-param name="prefix">
                                <xsl:choose>
                                    <xsl:when test="starts-with($includes, 'collab|')">
                                        <xsl:value-of select="''"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>,&#10;</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                            <xsl:with-param name="key">collab</xsl:with-param>
                            <xsl:with-param name="value" select="."/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="item">
                            <xsl:with-param name="prefix">
                                <xsl:choose>
                                    <xsl:when test="starts-with($includes, 'surname|')">
                                        <xsl:value-of select="''"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>,&#10;</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                            <xsl:with-param name="key">surname</xsl:with-param>
                            <xsl:with-param name="value">
                                <xsl:apply-templates select="surname" mode="formatting"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="item">
                            <xsl:with-param name="prefix">
                                <xsl:choose>
                                    <xsl:when test="starts-with($includes, 'given-names|')">
                                        <xsl:value-of select="''"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>,&#10;</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                            <xsl:with-param name="key">given-names</xsl:with-param>
                            <xsl:with-param name="value" select="given-names"/>
                        </xsl:call-template>
                        <xsl:call-template name="item">
                            <xsl:with-param name="prefix">
                                <xsl:choose>
                                    <xsl:when test="starts-with($includes, 'suffix|')">
                                        <xsl:value-of select="''"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>,&#10;</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                            <xsl:with-param name="key">suffix</xsl:with-param>
                            <xsl:with-param name="value" select="suffix"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="position() != last()">
            <xsl:value-of select="',&#10;'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="contrib">
        <xsl:call-template name="collection">
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="value">
                <xsl:call-template name="item">
                    <xsl:with-param name="key">type</xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:choose>
                            <xsl:when test="@contrib-type">
                                <xsl:value-of select="@contrib-type"/>
                            </xsl:when>
                            <xsl:when test="on-behalf-of">
                                <xsl:value-of select="'on-behalf-of'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="prefix" select="''"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">surname</xsl:with-param>
                    <xsl:with-param name="value" select="name/surname"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">given-names</xsl:with-param>
                    <xsl:with-param name="value" select="name/given-names"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">suffix</xsl:with-param>
                    <xsl:with-param name="value" select="name/suffix"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">id</xsl:with-param>
                    <xsl:with-param name="value" select="@id"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">group-author-key</xsl:with-param>
                    <xsl:with-param name="value" select="contrib-id[@contrib-id-type='group-author-key']"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">role</xsl:with-param>
                    <xsl:with-param name="value" select="role"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">on-behalf-of</xsl:with-param>
                    <xsl:with-param name="value" select="on-behalf-of"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">equal-contrib</xsl:with-param>
                    <xsl:with-param name="value" select="@equal-contrib"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">corresp</xsl:with-param>
                    <xsl:with-param name="value" select="@corresp"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">deceased</xsl:with-param>
                    <xsl:with-param name="value" select="@deceased"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">collab</xsl:with-param>
                    <xsl:with-param name="value" select="collab"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">email</xsl:with-param>
                    <xsl:with-param name="value" select="email"/>
                </xsl:call-template>
                <xsl:call-template name="item">
                    <xsl:with-param name="key">orcid</xsl:with-param>
                    <xsl:with-param name="value" select="contrib-id[@contrib-id-type='orcid']"/>
                </xsl:call-template>
                <xsl:call-template name="contrib-references">
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">affiliations</xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="aff" mode="contrib-referenced-aff">
                            <xsl:with-param name="multiple" select="1"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>

        <xsl:if test="position() != last()">
            <xsl:value-of select="',&#10;'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="contrib-references">
        <xsl:variable name="includes">
            <xsl:if test="xref[@ref-type='aff'][@rid]">
                <xsl:value-of select="'affiliation|'"/>
            </xsl:if>
            <xsl:if test="xref[@ref-type='corresp'][@rid]">
                <xsl:value-of select="'email|'"/>
            </xsl:if>
            <xsl:if test="xref[@ref-type='fn'][starts-with(@rid, 'equal-contrib')][@rid]">
                <xsl:value-of select="'equal-contrib|'"/>
            </xsl:if>
            <xsl:if test="xref[@ref-type='other'][starts-with(@rid, 'par-')][@rid]">
                <xsl:value-of select="'funding|'"/>
            </xsl:if>
            <xsl:if test="xref[@ref-type='fn'][starts-with(@rid, 'con')][not(starts-with(@rid, 'conf'))][@rid]">
                <xsl:value-of select="'contribution|'"/>
            </xsl:if>
            <xsl:if test="xref[@ref-type='fn'][starts-with(@rid, 'conf')][@rid]">
                <xsl:value-of select="'competing-interest|'"/>
            </xsl:if>
            <xsl:if test="xref[@ref-type='fn'][starts-with(@rid, 'pa')][@rid]">
                <xsl:value-of select="'present-address|'"/>
            </xsl:if>
            <xsl:if test="xref[@ref-type='other'][starts-with(@rid, 'dataro')][@rid]">
                <xsl:value-of select="'related-object|'"/>
            </xsl:if>
            <xsl:if test="xref[@ref-type='fn'][starts-with(@rid, 'fn')][@rid]">
                <xsl:value-of select="'foot-note|'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:call-template name="collection">
            <xsl:with-param name="key">references</xsl:with-param>
            <xsl:with-param name="value">
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">affiliation</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'affiliation|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='aff'][@rid]" mode="contrib-reference">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">email</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'email|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='corresp'][@rid]" mode="contrib-reference">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">equal-contrib</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'equal-contrib|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='fn'][starts-with(@rid, 'equal-contrib')][@rid]" mode="contrib-reference">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">funding</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'funding|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='other'][starts-with(@rid, 'par-')][@rid]" mode="contrib-reference">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">contribution</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'contribution|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='fn'][starts-with(@rid, 'con')][not(starts-with(@rid, 'conf'))][@rid]" mode="contrib-reference">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">competing-interest</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'competing-interest|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='fn'][starts-with(@rid, 'conf')][@rid]" mode="contrib-reference">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">present-address</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'present-address|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='fn'][starts-with(@rid, 'pa')][@rid]" mode="contrib-reference">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">related-object</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'related-object|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='other'][starts-with(@rid, 'dataro')][@rid]" mode="contrib-reference">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">foot-note</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'foot-note|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="xref[@ref-type='fn'][starts-with(@rid, 'fn')][@rid]" mode="contrib-reference"/>
                    </xsl:with-param>
                    <xsl:with-param name="value_prefix" select="'['"/>
                    <xsl:with-param name="value_suffix" select="']'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*" mode="contrib-reference">
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="@rid">
                    <xsl:value-of select="@rid"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:text>"</xsl:text>
        <xsl:value-of select="$value"/>
        <xsl:text>"</xsl:text>

        <xsl:if test="position() != last()">
            <xsl:value-of select="',&#10;'"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="contrib-referenced">
        <xsl:variable name="includes">
            <xsl:if test="//contrib-group//aff[@id]">
                <xsl:value-of select="'affiliation|'"/>
            </xsl:if>
            <xsl:if test="//author-notes/corresp[@id]">
                <xsl:value-of select="'email|'"/>
            </xsl:if>
            <xsl:if test="//author-notes/fn[@fn-type='con'][@id]">
                <xsl:value-of select="'equal-contrib|'"/>
            </xsl:if>
            <xsl:if test="//funding-group/award-group[@id]">
                <xsl:value-of select="'funding|'"/>
            </xsl:if>
            <xsl:if test="//fn-group[@content-type='author-contribution']/fn[@fn-type='con'][@id]">
                <xsl:value-of select="'contribution|'"/>
            </xsl:if>
            <xsl:if test="//fn-group[@content-type='competing-interest']/fn[@fn-type='conflict'][@id]">
                <xsl:value-of select="'competing-interest|'"/>
            </xsl:if>
            <xsl:if test="//author-notes/fn[@fn-type='present-address'][@id]">
                <xsl:value-of select="'present-address|'"/>
            </xsl:if>
            <xsl:if test="//related-object[@id]">
                <xsl:value-of select="'related-object|'"/>
            </xsl:if>
            <xsl:if test="//author-notes/fn[starts-with(@id, 'fn')][@id]">
                <xsl:value-of select="'foot-note|'"/>
            </xsl:if>
        </xsl:variable>
        <xsl:call-template name="collection">
            <xsl:with-param name="key">referenced</xsl:with-param>
            <xsl:with-param name="value">
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">affiliation</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'affiliation|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//contrib-group//aff[@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'affiliation'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">email</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'email|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//author-notes/corresp[@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'email'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">equal-contrib</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'equal-contrib|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//author-notes/fn[@fn-type='con'][@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'equal-contrib'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">funding</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'funding|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//funding-group/award-group[@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'funding'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">contribution</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'contribution|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//fn-group[@content-type='author-contribution']/fn[@fn-type='con'][@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'contribution'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">competing-interest</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'competing-interest|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//fn-group[@content-type='competing-interest']/fn[@fn-type='conflict'][@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'competing-interest'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">present-address</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'present-address|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//author-notes/fn[@fn-type='present-address'][@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'present-address'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">related-object</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'related-object|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//related-object[@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'related-object'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="collection">
                    <xsl:with-param name="key">foot-note</xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="starts-with($includes, 'foot-note|')">
                                <xsl:value-of select="''"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>,&#10;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="//author-notes/fn[starts-with(@id, 'fn')][@id]" mode="contrib-referenced">
                            <xsl:with-param name="type" select="'foot-note'"/>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*" mode="contrib-referenced">
        <xsl:param name="type"/>

        <xsl:choose>
            <xsl:when test="$type = 'affiliation'">
                <xsl:call-template name="collection">
                    <xsl:with-param name="key" select="@id"/>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="." mode="contrib-referenced-aff">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="position() > 1">
                                <xsl:value-of select="',&#10;'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type = 'email'">
                <xsl:call-template name="item">
                    <xsl:with-param name="key" select="@id"/>
                    <xsl:with-param name="value" select="email[1]"/>
                    <xsl:with-param name="prefix">
                        <xsl:if test="position() > 1">
                            <xsl:value-of select="',&#10;'"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type = 'equal-contrib' or $type = 'contribution' or $type = 'competing-interest' or $type = 'present-address'">
                <xsl:call-template name="item">
                    <xsl:with-param name="key" select="@id"/>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="p[1]" mode="formatting"/>
                    </xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:if test="position() > 1">
                            <xsl:value-of select="',&#10;'"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type = 'funding'">
                <xsl:call-template name="collection">
                    <xsl:with-param name="key" select="@id"/>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="." mode="contrib-referenced-award-group">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="position() > 1">
                                <xsl:value-of select="',&#10;'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type = 'related-object'">
                <xsl:call-template name="item">
                    <xsl:with-param name="key" select="@id"/>
                    <xsl:with-param name="default_value" select="'{}'"/>
                    <xsl:with-param name="prefix">
                        <xsl:if test="position() > 1">
                            <xsl:value-of select="',&#10;'"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type = 'foot-note'">
                <xsl:call-template name="collection">
                    <xsl:with-param name="key" select="@id"/>
                    <xsl:with-param name="value">
                        <xsl:apply-templates select="." mode="contrib-referenced-foot-note">
                        </xsl:apply-templates>
                    </xsl:with-param>
                    <xsl:with-param name="prefix">
                        <xsl:choose>
                            <xsl:when test="position() > 1">
                                <xsl:value-of select="',&#10;'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="aff" mode="contrib-referenced-aff">
        <xsl:param name="multiple" select="0"/>
        <xsl:variable name="includes">
            <xsl:choose>
                <xsl:when test="normalize-space(institution[@content-type='dept']) != ''">
                    <xsl:value-of select="'dept|'"/>
                </xsl:when>
                <xsl:when test="normalize-space(institution[not(@content-type='dept')]) != ''">
                    <xsl:value-of select="'institution|'"/>
                </xsl:when>
                <xsl:when test="normalize-space(addr-line/named-content[@content-type='city']) != ''">
                    <xsl:value-of select="'city|'"/>
                </xsl:when>
                <xsl:when test="normalize-space(country) != ''">
                    <xsl:value-of select="'country|'"/>
                </xsl:when>
                <xsl:when test="normalize-space(email) != ''">
                    <xsl:value-of select="'email|'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="$includes != ''">
                    <xsl:call-template name="item">
                        <xsl:with-param name="prefix">
                            <xsl:choose>
                                <xsl:when test="starts-with($includes, 'dept|')">
                                    <xsl:value-of select="''"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>,&#10;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="key">dept</xsl:with-param>
                        <xsl:with-param name="value">
                            <xsl:apply-templates select="institution[@content-type='dept']" mode="formatting"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="prefix">
                            <xsl:choose>
                                <xsl:when test="starts-with($includes, 'institution|')">
                                    <xsl:value-of select="''"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>,&#10;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="key">institution</xsl:with-param>
                        <xsl:with-param name="value">
                            <xsl:apply-templates select="institution[not(@content-type='dept')]" mode="formatting"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="prefix">
                            <xsl:choose>
                                <xsl:when test="starts-with($includes, 'city|')">
                                    <xsl:value-of select="''"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>,&#10;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="key">city</xsl:with-param>
                        <xsl:with-param name="value" select="addr-line/named-content[@content-type='city']"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="prefix">
                            <xsl:choose>
                                <xsl:when test="starts-with($includes, 'country|')">
                                    <xsl:value-of select="''"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>,&#10;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="key">country</xsl:with-param>
                        <xsl:with-param name="value" select="country"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="prefix">
                            <xsl:choose>
                                <xsl:when test="starts-with($includes, 'email|')">
                                    <xsl:value-of select="''"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>,&#10;</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="key">email</xsl:with-param>
                        <xsl:with-param name="value" select="email"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="item">
                        <xsl:with-param name="prefix" select="''"/>
                        <xsl:with-param name="key">dept</xsl:with-param>
                        <xsl:with-param name="value">
                            <xsl:apply-templates select="." mode="formatting"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$multiple = 1">
                <xsl:choose>
                    <xsl:when test="position() > 1">
                        <xsl:value-of select="',&#10;'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:call-template name="collection">
                    <xsl:with-param name="prefix" select="''"/>
                    <xsl:with-param name="value" select="$value"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="fn" mode="contrib-referenced-foot-note">
        <xsl:variable name="includes">
            <xsl:choose>
                <xsl:when test="@fn-type">
                    <xsl:value-of select="'type|'"/>
                </xsl:when>
                <xsl:when test="p[1]">
                    <xsl:value-of select="'value|'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="item">
            <xsl:with-param name="prefix">
                <xsl:choose>
                    <xsl:when test="starts-with($includes, 'type|')">
                        <xsl:value-of select="''"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="key">type</xsl:with-param>
            <xsl:with-param name="value" select="@fn-type"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="prefix">
                <xsl:choose>
                    <xsl:when test="starts-with($includes, 'value|')">
                        <xsl:value-of select="''"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="key">value</xsl:with-param>
            <xsl:with-param name="value" select="p[1]"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="award-group" mode="contrib-referenced-award-group">
        <xsl:variable name="includes">
            <xsl:choose>
                <xsl:when test="funding-source/institution-wrap/institution-id">
                    <xsl:value-of select="'id|'"/>
                </xsl:when>
                <xsl:when test="funding-source/institution-wrap/institution-id[@institution-id-type]">
                    <xsl:value-of select="'id-type|'"/>
                </xsl:when>
                <xsl:when test="funding-source/institution-wrap/institution">
                    <xsl:value-of select="'institution|'"/>
                </xsl:when>
                <xsl:when test="award-id">
                    <xsl:value-of select="'award-id|'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="item">
            <xsl:with-param name="prefix">
                <xsl:choose>
                    <xsl:when test="starts-with($includes, 'id|')">
                        <xsl:value-of select="''"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="key">id</xsl:with-param>
            <xsl:with-param name="value" select="funding-source/institution-wrap/institution-id"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="prefix">
                <xsl:choose>
                    <xsl:when test="starts-with($includes, 'id-type|')">
                        <xsl:value-of select="''"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="key">id-type</xsl:with-param>
            <xsl:with-param name="value" select="funding-source/institution-wrap/institution-id/@institution-id-type"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="prefix">
                <xsl:choose>
                    <xsl:when test="starts-with($includes, 'institution|')">
                        <xsl:value-of select="''"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="key">institution</xsl:with-param>
            <xsl:with-param name="value" select="funding-source/institution-wrap/institution"/>
        </xsl:call-template>
        <xsl:call-template name="item">
            <xsl:with-param name="prefix">
                <xsl:choose>
                    <xsl:when test="starts-with($includes, 'award-id|')">
                        <xsl:value-of select="''"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>,&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="key">award-id</xsl:with-param>
            <xsl:with-param name="value" select="award-id"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="fragments">
        <xsl:apply-templates select="//object-id[@pub-id-type='doi'] | //sub-article//article-id[@pub-id-type='doi']" mode="pub_id"/>
    </xsl:template>

    <xsl:template match="*" mode="pub_id">
        <xsl:param name="level" select="0"/>
        <xsl:choose>
            <xsl:when test="name() = 'article-id'">
                <xsl:apply-templates select="../.." mode="fragment">
                    <xsl:with-param name="doi" select="text()"/>
                    <xsl:with-param name="prefix">
                        <xsl:if test="position() > 1"><xsl:value-of select="',&#10;'"/></xsl:if>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="name() = 'object-id'">
                <xsl:choose>
                    <xsl:when test="name(..) = 'fig' and not(../@specific-use = 'child-fig') and name(../..) = 'fig-group'">
                        <xsl:apply-templates select="../.." mode="fragment">
                            <xsl:with-param name="doi" select="text()"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="prefix">
                                <xsl:if test="position() > 1"><xsl:value-of select="',&#10;'"/></xsl:if>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select=".." mode="fragment">
                            <xsl:with-param name="doi" select="text()"/>
                            <xsl:with-param name="level" select="$level"/>
                            <xsl:with-param name="prefix">
                                <xsl:if test="position() > 1"><xsl:value-of select="',&#10;'"/></xsl:if>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="fragment">
        <xsl:param name="prefix" select="''"/>
        <xsl:param name="doi"/>
        <xsl:param name="level" select="0"/>
        <xsl:variable name="ancestors" select="ancestor::fig-group/fig[not(@specific-use = 'child-fig')]/object-id[@pub-id-type='doi'] | ancestor::*/object-id[@pub-id-type='doi']"/>
        <xsl:variable name="descendants" select=".//object-id[@pub-id-type='doi'][not(text() = $doi)]"/>
        <xsl:choose>
            <xsl:when test="count($ancestors) = $level">
                <xsl:call-template name="collection">
                    <xsl:with-param name="prefix" select="$prefix"/>
                    <xsl:with-param name="value">
                        <xsl:call-template name="item">
                            <xsl:with-param name="prefix" select="''"/>
                            <xsl:with-param name="key">type</xsl:with-param>
                            <xsl:with-param name="value"><xsl:apply-templates select="." mode="fragment-type"/></xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="item">
                            <xsl:with-param name="key">subtype</xsl:with-param>
                            <xsl:with-param name="value" select="@abstract-type | @article-type"/>
                        </xsl:call-template>
                        <xsl:call-template name="item">
                            <xsl:with-param name="key">doi</xsl:with-param>
                            <xsl:with-param name="value" select="$doi"/>
                        </xsl:call-template>
                        <xsl:call-template name="item">
                            <xsl:with-param name="key">title</xsl:with-param>
                            <xsl:with-param name="value"><xsl:apply-templates select="." mode="fragment-label"/></xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="collection">
                            <xsl:with-param name="key">fragments</xsl:with-param>
                            <xsl:with-param name="value_prefix" select="'['"/>
                            <xsl:with-param name="value">
                                <xsl:apply-templates select="$descendants" mode="pub_id">
                                    <xsl:with-param name="level" select="$level + 1"/>
                                </xsl:apply-templates>
                            </xsl:with-param>
                            <xsl:with-param name="value_suffix" select="']'"/>
                        </xsl:call-template>
                        <xsl:call-template name="collection">
                            <xsl:with-param name="key">contributors</xsl:with-param>
                            <xsl:with-param name="value_prefix" select="'['"/>
                            <xsl:with-param name="value">
                                <xsl:apply-templates select="front-stub/contrib-group/contrib"/>
                            </xsl:with-param>
                            <xsl:with-param name="value_suffix" select="']'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="fragment-label">
        <xsl:choose>
            <xsl:when test="name() = 'fig-group'">
                <xsl:value-of select="fig[not(@specific-use='child-fig')]//label"/>
            </xsl:when>
            <xsl:when test="name() = 'sub-article'">
                <xsl:value-of select=".//article-title"/>
            </xsl:when>
            <xsl:when test=".//label">
                <xsl:value-of select=".//label"/>
            </xsl:when>
            <xsl:when test=".//title">
                <xsl:value-of select=".//title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="fragment-type">
        <xsl:choose>
            <xsl:when test="name() = 'fig-group'">
                <xsl:value-of select="'fig'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="volume">
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="//article-meta/volume">
                    <xsl:value-of select="//article-meta/volume"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="year"><xsl:call-template name="year"/></xsl:variable>
                    <xsl:value-of select="$year - 2011"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$value"/>
    </xsl:template>

    <xsl:template name="base_path">
        <xsl:variable name="volume"><xsl:call-template name="volume"/></xsl:variable>
        <xsl:variable name="eloc" select="//article-meta/elocation-id"/>
        <xsl:value-of select="concat('content/', $volume, '/', $eloc)"/>
    </xsl:template>

    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text, $replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text, $replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="formatting">
        <xsl:variable name="escape_backslash">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text"><xsl:apply-templates/></xsl:with-param>
                <xsl:with-param name="replace" select="'\'"/>
                <xsl:with-param name="by" select="'\\'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="escape_quotes">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$escape_backslash"/>
                <xsl:with-param name="replace" select="'&quot;'"/>
                <xsl:with-param name="by" select="'\&quot;'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="output" select="$escape_quotes"/>

        <xsl:value-of select="normalize-space($output)"/>
    </xsl:template>

    <xsl:template match="bold"><xsl:text disable-output-escaping="yes">&lt;strong&gt;</xsl:text><xsl:apply-templates/><xsl:text disable-output-escaping="yes">&lt;/strong&gt;</xsl:text></xsl:template>
    <xsl:template match="italic"><xsl:text disable-output-escaping="yes">&lt;em&gt;</xsl:text><xsl:apply-templates/><xsl:text disable-output-escaping="yes">&lt;/em&gt;</xsl:text></xsl:template>
    <xsl:template match="sup"><xsl:text disable-output-escaping="yes">&lt;sup&gt;</xsl:text><xsl:apply-templates/><xsl:text disable-output-escaping="yes">&lt;/sup&gt;</xsl:text></xsl:template>
    <xsl:template match="sub"><xsl:text disable-output-escaping="yes">&lt;sub&gt;</xsl:text><xsl:apply-templates/><xsl:text disable-output-escaping="yes">&lt;/sub&gt;</xsl:text></xsl:template>
</xsl:stylesheet>
