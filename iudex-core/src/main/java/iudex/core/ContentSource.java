/*
 * Copyright (c) 2008-2011 David Kellum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package iudex.core;

import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;

import com.gravitext.util.Streams;

public class ContentSource
{
    public ContentSource( CharSequence seq )
    {
        _source = seq;
    }

    public ContentSource( ByteBuffer buffer )
    {
        _source = buffer;
    }

    public ContentSource( InputStream in )
    {
        _source = in;
    }

    public InputStream stream()
    {
        if( _source instanceof InputStream ) {
            return (InputStream) _source;
        }
        else if( _source instanceof ByteBuffer ) {
            return Streams.inputStream( (ByteBuffer) _source );
        }
        return null;
    }

    public CharSequence characters()
    {
        return ( ( _source instanceof CharSequence ) ?
                 (CharSequence) _source : null );
    }

    public void setDefaultEncoding( Charset encoding )
    {
        _defaultEncoding = encoding;
    }

    /**
     * Default encoding if set (i.e. HTTP Content-Type; charset hint) or null
     * when the source is already characters.
     */
    public Charset defaultEncoding()
    {
        return _defaultEncoding;
    }

    public Object source()
    {
        return _source;
    }

    public void setEncodingConfidence( float confidence )
    {
        _encodingConfidence = confidence;
    }

    public float encodingConfidence()
    {
        return _encodingConfidence;
    }

    private Object  _source;
    private Charset _defaultEncoding = null;
    private float   _encodingConfidence = 0.0F;
}
