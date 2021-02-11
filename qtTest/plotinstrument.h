#ifndef PLOTINSTRUMENT_H
#define PLOTINSTRUMENT_H

#include <QObject>
#include <scope_sink_f.h>
#include <oscilloscope_plot.hpp>
#include <iiomanager.h>
#include "./ui_plotinstrument.h"

namespace adiscope {

class PlotInstrument : public QObject
{
	Q_OBJECT
public:
	std::vector<float> testData[2];
	QWidget *topLvlWidget;
	boost::shared_ptr<ScopyTopBlock> top;
	Ui::PlotInstrument *ui;
	PlotInstrument(boost::shared_ptr<ScopyTopBlock> top, QWidget* topLvlWidget, QObject *parent = nullptr);
	~PlotInstrument();

	CapturePlot *scopyPlot;
	std::vector<scope_sink_f::sptr> scope_sink;
public Q_SLOTS:
	void buildFlowGraph();
	void unbuildFlowGraph();
	void run();
	void stop();


private:
	double nb_points = 1023;
	double sample_rate = 1000;

};
}

#endif // PLOTINSTRUMENT_H
