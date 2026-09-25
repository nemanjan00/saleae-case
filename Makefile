OPENSCAD ?= openscad

CASE  = saleae_pro8_case.scad
GAUGE = radius_gauge.scad

.PHONY: all case gauge clean

all: case

case: case_bottom.stl case_top.stl

gauge: radius_gauge.stl radius_gauge_9-16.stl

case_bottom.stl: $(CASE)
	$(OPENSCAD) -D 'part="bottom"' -o $@ $<

case_top.stl: $(CASE)
	$(OPENSCAD) -D 'part="top_print"' -o $@ $<

radius_gauge.stl: $(GAUGE)
	$(OPENSCAD) -o $@ $<

radius_gauge_9-16.stl: $(GAUGE)
	$(OPENSCAD) -D 'radii=[9,10,11,12,13,14,15,16]' -o $@ $<

clean:
	rm -f case_bottom.stl case_top.stl radius_gauge.stl radius_gauge_9-16.stl
