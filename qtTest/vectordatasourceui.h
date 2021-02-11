#ifndef VECTORDATASOURCEUI_H
#define VECTORDATASOURCEUI_H

#include <mainwindow.h>
#include <QWidget>

#include <gnuradio/basic_block.h>
#include <gnuradio/blocks/vector_source.h>

namespace Ui {
class VectorDataSourceUi;
}

class VectorDataSourceUi : public QWidget
{
	Q_OBJECT

public:
	explicit VectorDataSourceUi(adiscope::DataSource *ds, QWidget *parent = nullptr);
	~VectorDataSourceUi();

private Q_SLOTS:
	void on_comboBox_currentIndexChanged(int index);

	void on_checkBox_stateChanged(int arg1);

private:
	adiscope::DataSource *ds;
	Ui::VectorDataSourceUi *ui;
	std::vector<float> testData[2];
};

#endif // VECTORDATASOURCEUI_H
