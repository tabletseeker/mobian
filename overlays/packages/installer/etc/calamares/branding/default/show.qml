/* === This file is part of Calamares - <https://github.com/calamares> ===
 *
 *   Copyright 2015, Teo Mrnjavac <teo@kde.org>
 *   Copyright 2015-2018, Anke Boersma <demm@kaosx.us>
 *
 *   Calamares is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   Calamares is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Calamares. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Timer {
        interval: 6000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        anchors.fill: parent

        Image {
            id: background
            source: "wallpaper.png"
            anchors.fill: parent
        }
    }

    Slide {
        anchors.fill: parent

        Image {
            id: background1
            source: "slide1.png"
            anchors.fill: parent
        }
    }

    Slide {
        anchors.fill: parent

        Image {
            id: background2
            source: "slide2.png"
            anchors.fill: parent
        }
    }

    Slide {
        anchors.fill: parent

        Image {
            id: background3
            source: "slide3.png"
            anchors.fill: parent
        }
    }

    Slide {
        anchors.fill: parent

        Image {
            id: background4
            source: "slide4.png"
            anchors.fill: parent
        }
    }

    Slide {
        anchors.fill: parent

        Image {
            id: background5
            source: "slide5.png"
            anchors.fill: parent
        }
    }
    
    Slide {
        anchors.fill: parent

        Image {
            id: background6
            source: "slide6.png"
            anchors.fill: parent
        }
    }
    
    Slide {
        anchors.fill: parent

        Image {
            id: background7
            source: "slide7.png"
            anchors.fill: parent
        }
    }
    
    Slide {
        anchors.fill: parent

        Image {
            id: background8
            source: "slide8.png"
            anchors.fill: parent
        }
    }
    
    Slide {
        anchors.fill: parent

        Image {
            id: background9
            source: "slide9.png"
            anchors.fill: parent
        }
    }
    
    Slide {
        anchors.fill: parent

        Image {
            id: background10
            source: "slide10.png"
            anchors.fill: parent
        }
    }
    
    Slide {
        anchors.fill: parent

        Image {
            id: background11
            source: "slide11.png"
            anchors.fill: parent
        }
    }
    
    Slide {
        anchors.fill: parent

        Image {
            id: background12
            source: "wallpaper2.png"
            anchors.fill: parent
        }
    }
}
