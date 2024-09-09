import '../css/components/landingMain.css';
import LandingTopLeft from '../assets/LandingTopLeft.png';
import Phones from '../assets/Phones.png';
import LandingBottom from '../assets/LandingBottom.png';

function LandingMain() {
    return (
        <div className='Content'>
            <div className='TopSide'>
                <div className="TopLeft">
                    <img src={LandingTopLeft} alt="Logo"/>
                </div>
                <div className="TopRight">
                    <img src={Phones} alt="Logo"/>
                </div>
            </div>
            <div className='BottomSide'>
            <img src={LandingBottom} alt="Logo"/>
            </div>
        </div>

    )
}

export default LandingMain;