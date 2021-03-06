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

package iudex.filter;

import com.gravitext.htmap.UniMap;

public interface FilterListener
{
    /**
     * Receive reject event.
     * @param filter which returned false
     * @param reject state on return from filter
     */
    void rejected( Filter filter, UniMap reject );

    /**
     * Receive failed event.
     * @param filter from which x was thrown
     * @param reject state at catch site
     * @param x the FilerException which was caught
     */
    void failed( Filter filter, UniMap reject, FilterException x );

    /**
     * Receive an accepted event (all filters returned true).
     * @param result the final state
     */
    void accepted( UniMap result );
}
