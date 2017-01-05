#!/bin/bash

for dir in */; do
    file="${dir}build.js"
    if [ -f "$file" ] ; then 
        sed -i "/})/d"  "$file"
        sed -i "s/}$/},/"  "$file"
        cat <<-EOF >> "$file"

    // support IE8 on r.js 2.2+ and uglify 2.x
    uglify2: {
        max_line_length: 32 * 1024,
        compress: {
            screw_ie8: false
        }
    }
})
EOF
    fi
done



