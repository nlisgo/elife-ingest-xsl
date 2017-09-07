<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/">
        <xsl:call-template name="collection">
            <xsl:with-param name="prefix" select="''"/>
            <xsl:with-param name="value_prefix" select="'['"/>
            <xsl:with-param name="value"><xsl:call-template name="posts"/></xsl:with-param>
            <xsl:with-param name="value_suffix" select="']'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="item">
        <xsl:param name="prefix" select="',&#10;'"/>
        <xsl:param name="key"/>
        <xsl:param name="value" select="''"/>
        <xsl:param name="default_value" select="''"/>
        <xsl:param name="string" select="'true'"/>
        <xsl:if test="normalize-space($value) != '' or $default_value != ''">
            <xsl:value-of select="$prefix"/>
            <xsl:text>"</xsl:text>
            <xsl:value-of select="$key"/>
            <xsl:text>": </xsl:text>
            <xsl:choose>
                <xsl:when test="normalize-space($value) != ''">
                    <xsl:if test="$string = 'true'">
                        <xsl:text>"</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="$value"/>
                    <xsl:if test="$string = 'true'">
                        <xsl:text>"</xsl:text>
                    </xsl:if>
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
        <xsl:param name="offset_prefix" select="0"/>
        <xsl:param name="key" select="''"/>
        <xsl:param name="value"/>
        <xsl:param name="value_prefix" select="'{'"/>
        <xsl:param name="value_suffix" select="'}'"/>
        <xsl:if test="$value != '' or $force != 0">
            <xsl:if test="position() > $offset_prefix and $prefix != ''">
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

    <xsl:template name="posts">
        <xsl:variable name="posts_output">
            <xsl:for-each select="//post">
                <xsl:if test="thread[@id] and ancestor::disqus/thread[@id='4612775086']">
                    <xsl:apply-templates select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring-after($posts_output, ',&#10;')"/>
    </xsl:template>

    <xsl:template match="post">
        <xsl:variable name="thread_id" select="thread/@id"/>
        <xsl:if test="isDeleted/text() = 'false' and isSpam/text() = 'false' and ancestor::disqus/thread[@id=$thread_id]">
            <xsl:call-template name="collection">
                <xsl:with-param name="value">
                    <xsl:call-template name="item">
                        <xsl:with-param name="prefix" select="''"/>
                        <xsl:with-param name="key">@context</xsl:with-param>
                        <xsl:with-param name="value" select="'http://www.w3.org/ns/anno.jsonld'"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">id</xsl:with-param>
                        <xsl:with-param name="value" select="concat('disqus-import:', @id)"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">type</xsl:with-param>
                        <xsl:with-param name="value" select="'Annotation'"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">created</xsl:with-param>
                        <xsl:with-param name="value" select="createdAt"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">modified</xsl:with-param>
                        <xsl:with-param name="value" select="createdAt"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">creator</xsl:with-param>
                        <xsl:with-param name="value" select="'acct:username@authority'"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">email</xsl:with-param>
                        <xsl:with-param name="value" select="author/email"/>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">body</xsl:with-param>
                        <xsl:with-param name="value">
                            <xsl:apply-templates select="message" mode="formatting"/>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">motivation</xsl:with-param>
                        <xsl:with-param name="value">
                            <xsl:choose>
                                <xsl:when test="parent">
                                    <xsl:value-of select="'replying'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'commenting'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">target</xsl:with-param>
                        <xsl:with-param name="value">
                            <xsl:choose>
                                <xsl:when test="parent">
                                    <xsl:value-of select="concat('disqus-import:', parent/@id)"/>
                                </xsl:when>
                                <xsl:when test="starts-with(ancestor::disqus/thread[@id=$thread_id]/id, 'article:')">
                                    <xsl:value-of select="concat('https://elifesciences.org/articles/', substring-after(ancestor::disqus/thread[@id=$thread_id]/id, 'article:'))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ancestor::disqus/thread[@id=$thread_id]/link"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="item">
                        <xsl:with-param name="key">name</xsl:with-param>
                        <xsl:with-param name="value">
                            <xsl:choose>
                                <xsl:when test="author/name">
                                    <xsl:value-of select="author/name"/>
                                </xsl:when>
                                <xsl:when test="author/username">
                                    <xsl:value-of select="author/username"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'__none__'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
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
</xsl:stylesheet>
