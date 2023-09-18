# ¥ 2.ch.8.1.3 プログラム一覧表示・詳細表示機能(顧客向け)
# class Customer::ProgramsController < ApplicationController
class Customer::ProgramsController < Customer::Base
  def index
    # - .publishedは program.rb に記載されたsqlのスコープ
    @programs = Program.published.page(params[:page])
  end

  def show
    @program = Program.published.find(params[:id])
  end
end
