package com.applovin.godot;

import android.app.Activity;
import android.os.Bundle;
import android.os.Parcelable;

import org.godotengine.godot.Dictionary;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class Utils
{
    static Map<String, String> toJavaStringMap(final Dictionary dictionary)
    {
        final Map<String, String> result = new HashMap();
        for ( final Map.Entry<?, ?> metaDataEntry : dictionary.entrySet() )
        {
            final Object key = metaDataEntry.getKey();
            final Object value = metaDataEntry.getValue();
            if ( key instanceof String && value instanceof String )
            {
                result.put( (String) key, (String) value );
            }
        }

        return result;
    }

    static Dictionary toGodotDictionary(final Bundle bundle)
    {
        if ( bundle == null ) return new Dictionary();

        Dictionary dictionary = new Dictionary();

        for ( String key : bundle.keySet() )
        {
            final Object value = bundle.get( key );
            if ( value == null ) continue;

            if ( value instanceof Bundle )
            {
                dictionary.put( key, toGodotDictionary( (Bundle) value ) );
            }
            // Convert Bundle lists/arrays (if value is a non-Bundle array we can just add it to the map directly)
            else if ( value instanceof Collection || value instanceof Parcelable[] )
            {
                final Collection items = ( value instanceof Collection ) ? (Collection) value : Arrays.asList( (Parcelable[]) value );
                final ArrayList<Object> objects = new ArrayList<>();
                for ( Object item : items )
                {
                    if ( item instanceof Bundle )
                    {
                        objects.add( toGodotDictionary( (Bundle) item ) );
                    }
                    else
                    {
                        objects.add( item );
                    }
                }
                dictionary.put( key, objects.toArray() );
            }
            else
            {
                dictionary.put( key, value );
            }
        }

        return dictionary;
    }

    static void runSafelyOnUiThread(final Activity activity, final Runnable runner)
    {
        activity.runOnUiThread( new Runnable()
        {
            @Override
            public void run()
            {
                try
                {
                    runner.run();
                }
                catch ( Exception e )
                {
                    e.printStackTrace();
                }
            }
        } );
    }
}

