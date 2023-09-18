# 2.ch6.2
class Staff::ProgramsController < Staff::Base
  def index
    # @programs = Program.order(application_start_time: :desc).page(params[:page])
    # - N+1 問題解消  2.ch6.3.1
    # @programs = Program.order(application_start_time: :desc).includes(:registrant).page(params[:page])
    # - models/program.rb の scope :listing, を参照している
    @programs = Program.listing.page(params[:page])
  end

  def show
    # @program = Program.find(params[:id])
    # ¥ 2.ch6.3.4 このアクションのERBテンプレートでも ProgramPresenter#number_of_applicants メソッドを呼び出しているため、 number_of_applicants という“カラム”を含む検索結果をデータベースから受け取る必要があるため、下記のように修正が必要
    @program = Program.listing.find(params[:id])
  end

  def new
    @program = Program.new
  end

  def edit
    @program = Program.find(params[:id])
    @program.init_virtual_attributes
  end

  def create
    @program = Program.new
    @program.assign_attributes(program_params)
    @program.registrant = current_staff_member
    if @program.save
      flash.notice = "プログラムを登録しました。"
      redirect_to action: "index"
    else
      flash.now.alert = "入力に誤りがあります。"
      render action: "new"
    end
  end

  def update
    @program = Program.find(params[:id])
    @program.assign_attributes(program_params)
    if @program.save
      flash.notice = "プログラムを更新しました。"
      redirect_to action: "index"
    else
      flash.now.alert = "⼊⼒に誤りがあります。"
      render action: "edit"
    end
  end

  private def program_params
    params.require(:program).permit([
      :title,
      :application_start_date,
      :application_start_hour,
      :application_start_minute,
      :application_end_date,
      :application_end_hour,
      :application_end_minute,
      :min_number_of_participants,
      :max_number_of_participants,
      :description
    ])
  end

  # ¥ 2.ch7.2.3
  def destroy
    program = Program.find(params[:id])
    # program.destroy!
    # flash.notice = "プログラムを削除しました。"
    # ¥ 2.ch.7 章末問題
    if program.deletable?
      program.destroy!
      flash.notice = "プログラムを削除しました。"
    else
      flash.alert = "このプログラムは削除できません。"
    end
    redirect_to :staff_programs
  end



end