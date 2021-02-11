#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <iiomanager.h>
#include <QString>
#include <map>
#include <boost/make_shared.hpp>

#include <gnuradio/blocks/vector_source.h>
#include <scope_sink_f.h>
#include <oscilloscope_plot.hpp>
#include "plotinstrument.h"
#include <DisplayPlot.h>

#ifdef __ANDROID__
#include <QAndroidJniEnvironment>
#endif


QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE
namespace adiscope {


class DataSource {
public:

	DataSource() {}
	~DataSource(){}

	QString name;
	IioManager *man;
	gr::basic_block_sptr block;
	unsigned int outputs;
};

class DataSourceUi
{
public:
	DataSourceUi() {}
	~DataSourceUi(){}
	DataSource* ds;
	QWidget* widget;

};


class DataSourceFactory
{
public:

	DataSourceFactory() { }
	~DataSourceFactory() { }
	DataSource createDataSource(IioManager *man, QString type, int outputs);
	DataSourceUi createDataSourceUi(DataSource* ds, QString type, QWidget *parent=0);
};


class MainWindow : public QMainWindow
{
	Q_OBJECT

public:
	MainWindow(QWidget *parent = nullptr);
	~MainWindow();
	void gnuradioTest();
	IioManager *man;
	PlotInstrument *plotInstrument;
#ifdef __ANDROID__
	QAndroidJniEnvironment *jnienv;
#endif
	std::map<QString, DataSource> sources;
	std::map<QString, DataSourceUi> uis;


private Q_SLOTS:
	void addSource();
	void removeSource();
	void on_pushButton_libiio_clicked();
	void on_pushButton_libm2k_clicked();
	void on_pushButton_clicked();
	void on_pushButton_2_clicked();

Q_SIGNALS:
	void topBlockChanged();
private:
	Ui::MainWindow *ui;
};
}
#endif // MAINWINDOW_H
